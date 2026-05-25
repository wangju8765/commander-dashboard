#!/usr/bin/env python3
"""Push index.html to GitHub via Git Data API"""
import json, base64, os, urllib.request

TOKEN = os.popen('gh auth token').read().strip()
OWNER = 'wangju8765'
REPO = 'commander-dashboard'
API = 'https://api.github.com'

headers = {
    'Authorization': 'Bearer ' + TOKEN,
    'Content-Type': 'application/json',
    'Accept': 'application/vnd.github.v3+json'
}

def api(method, path, data=None):
    url = API + path
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        resp = urllib.request.urlopen(req)
        return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        print(f'HTTP Error {e.code}: {e.read().decode()[:200]}')
        return None

# 1. Read file and create blob
with open('/Users/zeno/Documents/Openclaw-Workspace/projects/commander-dashboard/index.html', 'rb') as f:
    content_b64 = base64.b64encode(f.read()).decode()

print('Creating blob...')
blob = api('POST', '/repos/' + OWNER + '/' + REPO + '/git/blobs', {
    'content': content_b64, 'encoding': 'base64'
})
if not blob: exit(1)
blob_sha = blob['sha']
print('Blob SHA:', blob_sha[:12])

# 2. Get latest commit
print('Getting latest commit...')
ref = api('GET', '/repos/' + OWNER + '/' + REPO + '/git/ref/heads/main')
if not ref: exit(1)
latest_sha = ref['object']['sha']
print('Latest commit:', latest_sha[:12])

# 3. Get current tree
commit = api('GET', '/repos/' + OWNER + '/' + REPO + '/git/commits/' + latest_sha)
if not commit: exit(1)
tree_sha = commit['tree']['sha']
print('Tree SHA:', tree_sha[:12])

# 4. Create new tree
print('Creating tree...')
new_tree = api('POST', '/repos/' + OWNER + '/' + REPO + '/git/trees', {
    'base_tree': tree_sha,
    'tree': [{'path': 'index.html', 'mode': '100644', 'type': 'blob', 'sha': blob_sha}]
})
if not new_tree: exit(1)
new_tree_sha = new_tree['sha']
print('New tree SHA:', new_tree_sha[:12])

# 5. Create commit
print('Creating commit...')
new_commit = api('POST', '/repos/' + OWNER + '/' + REPO + '/git/commits', {
    'message': 'fix: separate mobile/desktop views with JS toggle',
    'tree': new_tree_sha,
    'parents': [latest_sha]
})
if not new_commit: exit(1)
new_commit_sha = new_commit['sha']
print('New commit SHA:', new_commit_sha[:12])

# 6. Update branch
print('Updating branch...')
result = api('PATCH', '/repos/' + OWNER + '/' + REPO + '/git/refs/heads/main', {
    'sha': new_commit_sha, 'force': False
})
if result:
    print('✅ Success! Branch:', result['ref'], '->', result['object']['sha'][:12])
else:
    print('❌ Failed to update branch')
