const fs = require('fs');
const path = require('path');

// 只读自己插件目录下的东西，不出网、不执行外部命令
function loadNotes(pkgRoot) {
  const file = path.join(pkgRoot, 'notes.json');
  if (!fs.existsSync(file)) return [];
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function saveNotes(pkgRoot, notes) {
  const file = path.join(pkgRoot, 'notes.json');
  fs.writeFileSync(file, JSON.stringify(notes, null, 2), 'utf8');
}

module.exports = { loadNotes, saveNotes };
