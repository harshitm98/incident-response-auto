from notion.client import NotionClient
from notion.block import PageBlock
from md2notion.upload import upload
import json

with open("config.json", "r") as f:
    config_data = json.loads(f.read())

token_notion = config_data["notion_token_v2"]
client = NotionClient(token_v2=token_notion)
page = client.get_block("https://www.notion.so/fakebatman/Report-for-Incident-Response-62cafa4e5990465fa87ccd49f28c0a52")


def upload_report(mdFilename, report_title):
    with open(mdFilename, "r", encoding="utf-8") as mdFile:
        newPage = page.children.add_new(PageBlock, title=report_title)
        upload(mdFile, newPage) #Appends the converted contents of TestMarkdown.md to newPage


def update_report_contents(report_contents, file_name, folder_location, section_title = "", section_sub_title = "", section_description = ""):
    try:
        with open("{}/{}".format(folder_location, file_name)) as f:
            file_contents = str(f.read())
            if file_contents != "":
                if section_title != "":
                    report_contents += "\n## {}\n".format(section_title)
                if section_sub_title != "":
                    report_contents += "\n**{}**\n".format(section_sub_title)
                if section_description != "":
                    report_contents += "\n*{}*\n".format(section_description)
                
                report_contents += "```\n"
                report_contents += file_contents
                report_contents += "```\n"
    except FileNotFoundError as e:
        print("Ran into error while opening the file at {}/{}. Error: {}".format(folder_location, file_name, e))
    finally:    
        return report_contents


def create_md_file(folder_location, report_title):
    report_contents = ""

    ### OS Version
    report_contents = update_report_contents(report_contents, "os_version.txt", folder_location, section_title="OS Version")

    ### Host Installation time
    report_contents = update_report_contents(report_contents, "potential_os_installation_date.txt", folder_location, section_sub_title="Host Installation Details")

    ### Static IP Addresses
    report_contents = update_report_contents(report_contents, "static_ip_addresses.txt", folder_location, section_title="Static IP Addresses")

    ### Active Connections
    report_contents += "\n## Active Connections\n"

    report_contents = update_report_contents(report_contents, "active_connections_netstat.txt", folder_location, section_title="", section_sub_title="Netstat")

    report_contents = update_report_contents(report_contents, "active_connections_ss.txt", folder_location, section_title="", section_sub_title="SS")
    
    ### Running process
    report_contents = update_report_contents(report_contents, "running_processes.txt", folder_location, section_title="Currently running process")
    

    ### Users on the system
    report_contents = update_report_contents(report_contents, "users.txt", folder_location, section_title="Users on the system")

    ### Users with SUID bit set to 0
    report_contents = update_report_contents(report_contents, "users_suid_eq_0.txt", folder_location, section_title="", section_sub_title="Users with SUID bit set to 0")

    ### Users who can run sudo
    report_contents = update_report_contents(report_contents, "users_sudo.txt", folder_location, section_title="", section_sub_title="Users who can run sudo")
 
    ### Bash history of the users
    report_contents += "\n## User specific data\n"
    
    users = []
    try:
        with open("{}/users.txt".format(folder_location), "r") as f:
            users = f.read().split("\n")

    except FileNotFoundError as e:
            print("Ran into error while opening the file at {}/{}. Error: {}".format(folder_location, "users.txt", e))

    for user in users:
        if user == "":
            continue

        report_contents += "\n ### {}".format(user)

        ### Bash history
        report_contents = update_report_contents(report_contents, "{0}/bash_history_{0}.txt".format(user), folder_location, section_title="", section_sub_title="Bash History")

        ### SSH files
        report_contents = update_report_contents(report_contents, "{}/ssh_files/authorized_keys.txt".format(user), folder_location, section_title="", section_sub_title="SSH Files - authorized_keys output")

        ### Browsing History
        report_contents = update_report_contents(report_contents, "{}/firefox_data/browsing_history/firefox_browsing_history.txt".format(user), folder_location, section_title="", section_sub_title="Web Browsing History - Firefox")



    with open("{}.md".format(report_title), "w+") as f:
        f.write(report_contents)

    upload_report("{}.md".format(report_title), report_title)

create_md_file("auto_script_output", "Incident Response")