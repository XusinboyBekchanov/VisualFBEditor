// WebIDE_lib.js: the functions of the Web IDE (VisualFBEditor.html) which are not the ones of MyFbFramework
// (mff_lib.js). It is linked with --js-library (the #cmdline of VisualFBEditor.bas, Temp/BuildWeb.ps1).

var WebIDELibrary = {
	// The browser can not start the compiler: the files of the folder Root (the project) are sent with POST /compile to
	// the server of the page (Service > Web IDE Server of the desktop IDE, WebCompile of TabWindow.bas), which compiles
	// them for the Web. The format of the request and of the answer is described there. The FreeBASIC code waits
	// (ASYNCIFY) for the answer (UTF-8, freed with FreePtr); 0 when another wait runs. RunPage: the page of the program
	// opens in a new tab. It is opened before the request: after the wait the browser does not allow a new tab any more
	COMPILEONSERVER__deps: ['$mff', '$Asyncify', '$FS', '$stringToNewUTF8'],
	COMPILEONSERVER__async: true,
	COMPILEONSERVER: function(Root, MainFile, Options, RunPage) {
		if (Asyncify.state === Asyncify.State.Normal && mff.cannotWait()) return 0;
		return Asyncify.handleSleep(function(wakeUp) {
			var root = mff.str(Root).replace(/\\/g, "/"), main = mff.str(MainFile).replace(/\\/g, "/");
			if (root.slice(-1) != "/") root += "/";
			// ?server=http://localhost:8001/ - another server than the one of the page
			var server = new URLSearchParams(location.search).get("server") || (location.origin + "/");
			if (server.slice(-1) != "/") server += "/";
			// the folder of the compilations of this page on the server
			if (!Module.webCompileId) Module.webCompileId = Math.random().toString(36).slice(2, 12);
			var enc = new TextEncoder(), parts = [], total = 0;
			var mainName = main.substring(main.lastIndexOf("/") + 1).replace(/\.[^.]*$/, "").toLowerCase();
			// the files which the compilation makes (not the ones of the project)
			var skip = /\.(exe|dll|o|obj|wasm|data|pdb|zip|7z|rar|log)$/i;
			var line = function(s) { parts.push(enc.encode(s.replace(/[\r\n]+/g, " ") + "\n")); };
			var walk = function(dir, rel, depth) {
				var names;
				try { names = FS.readdir(dir); } catch (err) { return; }
				names.forEach(function(n) {
					if (n == "." || n == "..") return;
					var p = dir + n, st;
					try { st = FS.stat(p); } catch (err) { return; }
					if (FS.isDir(st.mode)) {
						if (depth < 8 && n.charAt(0) != ".") walk(p + "/", rel + n + "/", depth + 1);
						return;
					}
					var base = n.replace(/\.[^.]*$/, "").toLowerCase(), ext = n.substring(base.length).toLowerCase();
					if (skip.test(n) || (base == mainName && (ext == ".html" || ext == ".js" || ext == ".c"))) return;
					if (st.size > (16 << 20) || total + st.size > (64 << 20)) return;
					var data = FS.readFile(p);
					total += data.length;
					line("file " + data.length + " " + rel + n);
					parts.push(data, enc.encode("\n"));
				});
			};
			line("VFBE-WEBCOMPILE 1");
			line("id " + Module.webCompileId);
			line("root " + root);
			line("main " + (main.indexOf(root) == 0 ? main.substring(root.length) : main));
			line("options " + mff.str(Options));
			walk(root, "", 0);
			line("end");
			var win = null;
			if (RunPage) {
				win = window.open("", "_blank");
				if (win) win.document.title = "Compiling...";
			}
			fetch(server + "compile", { method: "POST", body: new Blob(parts) }).then(function(r) {
				return r.text().then(function(t) {
					return r.ok || /^result=/.test(t) ? t : "result=0\nerror=" + server + "compile: " + r.status + " " + r.statusText + "\n";
				});
			}, function(err) {
				return "result=0\nerror=" + server + "compile: " + (err && err.message || err) + "\n";
			}).then(function(t) {
				var page = /^page=(.*)$/m.exec(t), url = "";
				// the page of the program of each main file: Start and Restart open the one of the main file (WEBRUNPAGE)
				if (/^result=1$/m.test(t) && page) {
					url = new URL(page[1], server).href;
					if (!Module.webPages) Module.webPages = {};
					Module.webPages[main.toLowerCase()] = url;
				}
				if (win) {
					if (url) win.location.href = url;
					else win.close();
				}
				wakeUp(stringToNewUTF8(t));
			});
		});
	}
};

// Start, Restart: the page of the program of the main file MainFile (its last compilation, COMPILEONSERVER) in a new
// tab; 0 - the main file was not compiled on this page
WebIDELibrary.WEBRUNPAGE__deps = ['$mff'];
WebIDELibrary.WEBRUNPAGE = function(MainFile) {
	var url = Module.webPages && Module.webPages[mff.str(MainFile).split("\\").join("/").toLowerCase()];
	if (!url) return 0;
	window.open(url, "_blank");
	return 1;
};

mergeInto(LibraryManager.library, WebIDELibrary);
