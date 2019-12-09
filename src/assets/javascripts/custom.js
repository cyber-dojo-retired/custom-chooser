
toggleOutputFile = () => {
  if (cd.isOutputFile(cd.currentFilename())) {
    cd.loadFile(theLastNonOutputFilename);
  } else {
    cd.loadFile(theLastOutputFilename);
  }
};
