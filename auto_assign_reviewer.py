import sys
import re
from typing import Any
import requests
import subprocess


class Gitlab:
    def __init__(
        self,
        access_token: str,
        project_id: str,
        merge_request_id: str,
        merge_request_iid: str,
    ) -> None:
        self.headers = {'Authorization': f'Bearer {access_token}'}
        self.base_url = 'https://gitlab.int.seedstars.com/api/v4'
        self.project_id = project_id
        self.merge_request_id = merge_request_id
        self.merge_request_iid = merge_request_iid

    def _get_active_users(self) -> dict[str, str]:
        """Fetch active users with atleast developer access."""
        response = requests.get(
            f'{self.base_url}/users',
            headers=self.headers,
            params={
                'active': 'true',
            },
        )

        response.raise_for_status()
        active_users = {user['username']: user['id'] for user in response.json()}

        return active_users

    def _search_users(self, username: str) -> str:
        """Search user using username and return user id."""
        response = requests.get(
            f'{self.base_url}/users',
            headers=self.headers,
            params={'username': username},
        )
        response.raise_for_status()

        if response.json() == []:
            return ""

        # Username should be unique accross gitlab
        user = response.json()[0]
        if user['state'] != 'active':
            # If user isn't active return empty string
            return ''
        #  We only need the id
        return user['id']

    def _get_maintainer_id(self) -> str:
        """Get project maintainer id."""
        # Project maintainer is assumed be responsible for the last merge commit.
        logs_process = subprocess.run(
            'git log --merges -n 1 --pretty=%an',
            shell=True,
            capture_output=True,
            text=True,
            check=True,
        )
        maintainer_name = logs_process.stdout.split()[0].lower()
        return self._search_users(maintainer_name)

    def _get_mr_changes(self) -> tuple[dict[str, Any], dict[str, str]]:
        """Get merge request changes."""
        response = requests.get(
            f'{self.base_url}/projects/{self.project_id}/merge_requests/{self.merge_request_iid}/changes',
            headers=self.headers,
        )
        response.raise_for_status()
        return response.json()['changes'], response.json()['author']

    def _get_eligible_reviewer_and_assignee(self) -> list[str]:
        """Get ids of reviewer and assignee."""
        can_assign = False
        reviewer_dict = {}
        proposed_reviewer_id = None
        changes, mr_author = self._get_mr_changes()

        # Compile regex pattern to get lines of code removed.
        # We don't care about added lines. 
        pattern = re.compile(r'@@ -([0-9]+(,[0-9]+)?)')
        for change in changes:
            # Ignore change if it is in a new file.
            if change.get('new_file'):
                continue
            
            # Get diffs and search for the compiled pattern
            matches = pattern.finditer(change['diff'])
            for match in matches:
                # Get removed lines, and use git blame to get the author that last modified it using the last merge commit. 
                # Last merge commit is assumed to be the latest commit of master.
                # Count and sort the authors in decreasing order of lines modified.
                authors_process = subprocess.run(
                    f'git blame $(git log --merges -n 1 --pretty=%h) -e -L {match.group(1)} {change["old_path"]} --line-porcelain | sed -n "s/^author //p" | sort | uniq -c | sort -rn',
                    shell=True,
                    capture_output=True,
                    text=True,
                    check=True,
                )
                for line in authors_process.stdout.splitlines():
                    count, author = line.split(maxsplit=1)
                    reviewer_dict[author] = reviewer_dict.get(author, 0) + int(count)

        previous_authors_list = sorted(
            reviewer_dict, key=reviewer_dict.get, reverse=True
        )
        eligibile_reviewers = self._get_active_users()

        for proposed_reviever in previous_authors_list:
            username = proposed_reviever.split()[0].lower()
            if username == mr_author['username']:
                # Move to the next eligibe reviewer if it matches the current author of this mr 
                continue

            # Check if the proposed reviewer is an active user in gitlab
            if proposed_reviewer_id := eligibile_reviewers.get(username):
                can_assign = True
                break

        assignee_id = mr_author['id']
        # We assign to the project maintainer if we can't find an eligible user
        reviewer_id = proposed_reviewer_id if can_assign else self._get_maintainer_id()

        return reviewer_id, assignee_id

    def update_mr_details(self) -> bool:
        """Update merge request."""
        reviewer_id, assignee_id = self._get_eligible_reviewer_and_assignee()

        # Return early if there is not reviwer id
        if not reviewer_id:
            return False

        response = requests.put(
            f'{self.base_url}/projects/{self.project_id}/merge_requests/{self.merge_request_iid}',
            headers=self.headers,
            data={
                'id': self.merge_request_id,
                'iid': self.merge_request_iid,
                'assignee_id': assignee_id,
                'reviewer_ids': [reviewer_id],
            },
        )
        response.raise_for_status()

        res_reviewer_id = (
            response.json()['reviewers'][0]['id']
            if response.json()['reviewers']
            else []
        )
        res_assignee_id = response.json()['assignee']['id']
        if reviewer_id != res_reviewer_id or assignee_id != res_assignee_id:
            return False

        return True


if __name__ == '__main__':
    print('starting auto-assigning of reviewer')

    if len(sys.argv) < 5:
        raise KeyError('Incomplete required positional keys.')

    gitlab = Gitlab(
        access_token=sys.argv[1],
        project_id=sys.argv[2],
        merge_request_id=sys.argv[3],
        merge_request_iid=sys.argv[4],
    )
        
    if gitlab.update_mr_details():
        print('Auto assigning was successful')
    else:
        print('Auto-assigning of reviewer failed')

# NOTICE: script is less efficient when the commit difference from master/main branch is greater than 50.
# This is because the git log depth set on gitlab is 50. This means script will only have access to the last
# 50 commits.
