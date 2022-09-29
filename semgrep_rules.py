import argparse

import requests
import semgrep
import yaml
from yaml import dump, load
from yaml.loader import SafeLoader


RULES_LIST: dict[str, list[str]] = {
    'python': ['https://semgrep.dev/c/r/python'],
    'javascript': ['https://semgrep.dev/c/r/javascript'],
    'typescript': ['https://semgrep.dev/c/r/typescript'],
}
EXCLUDE_LIST: dict[str, list[str]] = {
    'python': [
        'python.django.security.audit.django-ratelimit.missing-ratelimit.missing-ratelimit',
        'python.lang.maintainability.is-function-without-parentheses.is-function-without-parentheses',
        'python.django.security.audit.xss.direct-use-of-httpresponse.direct-use-of-httpresponse',
        'python.lang.security.audit.non-literal-import.non-literal-import',
        'python.jwt.security.audit.jwt-exposed-data.jwt-python-exposed-data',
        'python.requests.best-practice.use-raise-for-status.use-raise-for-status',
        # this rule has problems, but would be great if it would work
        'python.lang.correctness.common-mistakes.string-concat-in-list.string-concat-in-list',
        'python.lang.best-practice.logging-error-without-handling.logging-error-without-handling',
        'python.lang.security.use-defusedcsv.use-defusedcsv',
    ],
    'javascript': [],
    'typescript': [
        'typescript.react.security.audit.react-no-refs.react-no-refs',
        'typescript.react.portability.i18next.i18next-key-format.i18next-key-format',  # temporary
    ],
}


def selective_representer(dumper, data):
    """Process yml to correctly handle \n."""
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|' if '\n' in data else None)


yaml.add_representer(str, selective_representer)


def get_rules(rules: list[str], rules_version: str):
    """Get rules file with all rules excluding the ones we don't want to have."""

    final_rules: list[dict] = []
    for rule_choice in rules:
        for rule_list in RULES_LIST[rule_choice]:
            # get rules from semgrep registry
            print(f'Downloading {rule_choice} rules from semgrep registry...')
            response = requests.get(rule_list, headers={'User-Agent': f'Semgrep/{semgrep.__VERSION__}'})
            config_file = load(response.text, Loader=SafeLoader)
            rules = config_file['rules']
            updated_rules = [rule for rule in rules if rule['id'] not in EXCLUDE_LIST[rule_choice]]
            final_rules += updated_rules

            # get rules from our github  (we only have rules for python for now)
            if rule_choice in ['python', 'typescript']:
                print(f'Downloading {rule_choice} rules from our repository...')
                url = f'https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/{rules_version}/semgrep_rules_{rule_choice}.yml'
                response = requests.get(url)
                config_file = load(response.text, Loader=SafeLoader)
                rules = config_file['rules']
                updated_rules = [rule for rule in rules if rule['id'] not in EXCLUDE_LIST[rule_choice]]
                final_rules += updated_rules

    with open('./.semgrep_rules.yml', 'w', encoding='utf-8') as temp_rule_file:
        dump({'rules': final_rules}, temp_rule_file)


if __name__ in '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-r', '--rules', choices=['python', 'javascript', 'typescript'], nargs='+', required=True)
    parser.add_argument('-v', '--version', type=str, nargs='?', required=True)
    args = parser.parse_args()
    get_rules(args.rules, args.version)
