#!/usr/bin/python3

import glob, re, json

# Get Files From Package File
package_file = open('./package.json', 'r')
package_content = json.loads(package_file.read())

static_dir = package_content['setIntlToPo']['srcDir']
po_dir = package_content['setIntlToPo']['loacaleDir']

output_file_write_buffer = open(po_dir, 'a+')
output_file_read_buffer = open(po_dir, 'r')
po_content = output_file_read_buffer.read()

# List all Js Files

js_files_list = glob.glob('{}**/*.js'.format(static_dir), recursive=True)

# Set Regular Expresion
regular_expression = prog = re.compile("formatMessage\(\s*\{\s*id:\s*'([^']*)'\s*\}", re.X)

for file_name in js_files_list:
    file = open(file_name, 'r')
    file_content = file.read()
    matchs = regular_expression.findall(file_content)
    for locale_id in matchs:
        # Check po file have the string id
        if ("msgid \"{}\"\n".format(locale_id)) not in po_content:
            # Add to Po File
            output_file_write_buffer.write("#: {}\n".format(file_name))
            output_file_write_buffer.write("msgid \"{}\"\n".format(locale_id))
            output_file_write_buffer.write("msgstr \"{}\"\n\n".format(locale_id))
            # Add to content string
            po_content+= "#: {}\n".format(file_name)
            po_content+= "msgid \"{}\"\n".format(locale_id)
            po_content+= "msgstr \"{}\"\n\n".format(locale_id)
    file.close()

output_file_write_buffer.close()
output_file_read_buffer.close()
