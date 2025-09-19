
That error means Mason successfully cloned the Java Language Server repo, but when it tried to build it with Maven (`mvn package -DskipTests`), **Windows PowerShell** couldn’t find the `mvn` command:

```
The term 'mvn' is not recognized as a name of a cmdlet, function, script file, or executable program.
```

---

## Why this happens

* **`java-language-server`** (the Mason package) is a source‑based LSP that needs to be **built** locally with Maven.
* On Linux/macOS you’d typically have `mvn` installed; on Windows you likely don’t—so the build step fails.

---

## ✅ Fix: Install Apache Maven and Add It to Your PATH

1. **Download & Install Maven**

   * **Chocolatey** (if you have it):

     ```powershell
     choco install maven
     ```
   * **Scoop** (if you use Scoop):

     ```powershell
     scoop install maven
     ```
   * **Manual**:

     1. Download the binary zip from [https://maven.apache.org/download.cgi](https://maven.apache.org/download.cgi)
     2. Unzip to e.g. `C:\Program Files\Apache\Maven\apache-maven-3.x.y`
     3. Add `C:\Program Files\Apache\Maven\apache-maven-3.x.y\bin` to your **User** or **System** `PATH` environment variable.

2. **Verify** in a new PowerShell / CMD window:

   ```powershell
   mvn -v
   ```

   You should see Maven’s version info and your Java version.

3. **Restart Neovim** and re-run the Mason install:

   ```vim
   :MasonInstall java-language-server
   ```

   or if you use the tool installer:

   ```vim
   :MasonToolsInstall
   ```

---

## Alternative: Use a Prebuilt Java LSP

If you’d rather not install Maven, you can use **Eclipse’s JDT Language Server**, which Mason also provides as `jdtls`—it ships prebuilt binaries:

```vim
:MasonInstall jdtls
```

Then in your LSP config switch to the `jdtls` package instead of `java-language-server`.

---

### TL;DR

* **Install Maven** (via Chocolatey, Scoop, or manual), ensure `mvn` is in your `PATH`.
* **Re-run** Mason to let it build the Java Language Server.

Or, if you prefer **not** to build from source, install the prebuilt **JDTLS** with `:MasonInstall jdtls` and point your Java LSP setup at that.
