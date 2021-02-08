const fs = require('fs');
const async = require('async');
const vttToJson = require('vtt-to-json');

const channel = process.argv[2];
const args = process.argv.slice(3);
const limit = 1;

function readFiles(dirname, onFileContent, onError) {
  fs.readdir(dirname, (err, filenames) => {
    if (err) {
      onError(err);
      return;
    }
    filenames.sort(function(a, b){return 0.5 - Math.random()}); // Sort randomly
    // filenames.sort(function(a, b) {return fs.statSync(dirname + a).mtime.getTime() - fs.statSync(dirname + b).mtime.getTime()}); // Sort by modified time
    async.forEach(filenames, (filename) => {
      fs.readFile(dirname + filename, 'utf-8', (err, content) => {
        if (err) {
          onError(err);
          return;
        }
        onFileContent(filename, content);
      });
    });
  });
}

let data = {};
let count = 1;

readFiles( __dirname + '/channels/' + channel + '/vtt/', (filename, content) => {
  if (count > limit) {
    return; // limit readFiles loop count
  }
  data[filename] = content;
  let vttString = data[filename].toString();
  vttToJson(vttString)
  .then((captions) => {
    let wordSets = [];
    for (let i = 0; i < captions.length; i++) {
      wordSets.push(captions[i]);
    }
    wordSets.sort(function(a, b){return 0.5 - Math.random()}); // Sort randomly
    for (let i = 0; i < wordSets.length; i++) {
      let wordSet = wordSets[i];
      if (count > limit) {
        break; // limit wordSets returned
      } else if (new RegExp(args.join(' '), 'i').test(wordSet.part)) {
        console.log(filename.replace('.en.vtt', '') + ',' + parseInt(wordSet.start / 1000));
        count++;
      }
    }
  });
}, (err) => {
  throw err;
});
