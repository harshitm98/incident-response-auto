from notion.client import NotionClient
from notion.block import PageBlock
from md2notion.upload import upload
import json

# Follow the instructions at https://github.com/jamalex/notion-py#quickstart to setup Notion.py
with open("config.json", "r") as f:
    config_data = json.loads(f.read())

token_notion = config_data["notion_token_v2"]
client = NotionClient(token_v2=token_notion)
page = client.get_block("https://www.notion.so/fakebatman/Report-for-Incident-Response-62cafa4e5990465fa87ccd49f28c0a52")
print("The old title is:", page.title)

with open("README.md", "r", encoding="utf-8") as mdFile:
    newPage = page.children.add_new(PageBlock, title="TestMarkdown Upload")
    upload(mdFile, newPage) #Appends the converted contents of TestMarkdown.md to newPage
