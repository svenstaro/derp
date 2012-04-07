import derp.all;

import std.stdio;

int main(string[] args) {

    FileSystem root = new FileSystem("test");
    ZipFileSystem zip = new ZipFileSystem(root.readBytes("test_zip.zip"));

    assert(zip.exists("testDir/") == true);
    assert(zip.exists("invalidDir/") == false);
    assert(zip.exists("testDir/file") == true);
    assert(zip.getSize("testDir/file") == 8);
    assert(zip.readText("testDir/file") == "CONTENT\n");

    try {
        root.getSize("invalidFile");
        assert(0);
    } catch(FileNotFoundException e) {
        assert(e.file == "invalidFile");
        assert(e.fileSystem == root);
    }

    // MergedFileSystem both = new MergedFileSystem();
    // the higher in the array, the higher the priority
    // both.fileSystems ~= zip;
    // both.fileSystems ~= root;

    Derp app = new Derp();

    FilesystemResourceLoader frl = cast(FilesystemResourceLoader) app.resourceManager.loaders["filesystem"];
    frl.fileSystem.fileSystems ~= root;
    frl.fileSystem.fileSystems ~= zip;

    Resource double_file = app.resourceManager.load("double_file");
    writeln(double_file.text);

    return 0;
}
