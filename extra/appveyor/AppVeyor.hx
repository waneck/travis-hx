import sys.FileSystem.*;
import haxe.io.*;
import sys.io.*;
import hxcpp.StaticStd;
import hxcpp.StaticZlib;
import hxcpp.StaticRegexp;
using StringTools;

class AppVeyor
{

	public function new()
	{
	}

	static function main()
	{
		Sys.putEnv('PATH', Sys.getEnv('PATH') + ';C:\\HaxeToolkit\\neko;C:\\HaxeToolkit\\haxe');
		Sys.putEnv('HAXEPATH', 'C:\\HaxeToolkit\\haxe');
		Sys.putEnv('NEKO_INSTPATH', 'C:\\HaxeToolkit\\neko');
		switch (Sys.args()[0])
		{
			case 'setup':
				setup();
			case 'build':
				build();
			case 'hxcpp':
				setupHxcpp();
			case 'run':
				var args = Sys.args();
				args.shift();
				var c = args.shift();
				cmd(c,args);
			case 'retry':
				var args = Sys.args();
				args.shift();
				var c = args.shift();
				cmd(c,args,3);
			case 'download':
				var args = Sys.args();
				download(args[1], args[2]);
			case 'untar':
				var args = Sys.args();
				untar(args[1], args[2]);
			case 'test':
				test();
		}
	}

	static function test()
	{
		var targetDir = Sys.getEnv("TARGET_DIR");
		if (targetDir == null)
			targetDir = Sys.getCwd();
		while (true)
		{
			switch (targetDir.charAt(targetDir.length-1))
			{
				case '/' | '\\':
					targetDir = targetDir.substr(0,targetDir.length-1);
				default:
					break;
			}
		}

		var built = Sys.args()[1];
		if (built == '' || built.trim() == '') built = null;
		for (target in Sys.getEnv("TARGET").split(" "))
		{
			switch target
			{
				case 'js':
					var built = built;
					if (built == null) built = '$targetDir/js.js';
					if (Sys.getEnv("NODECMD") != null)
					{
						cmd('node',['-e',Sys.getEnv("NODECMD")]);
					} else {
						cmd('node',[built]);
					}
				case 'neko':
					var built = built;
					if (built == null) built = '$targetDir/neko.n';
					cmd('neko',[built]);
				case 'python':
					var built = built;
					if (built == null) built = '$targetDir/python.py';
					var pcmd = Sys.getEnv("PYTHONCMD");
					if (pcmd == null)
						pcmd = "python3";
					cmd(pcmd,[built]);
				case 'cpp' | 'cs':
					var built = built;
					if (built == null) built = '$targetDir/$target';
					if (isDirectory(built))
					{
						for (file in readDirectory(built))
						{
							if (file.endsWith('.exe'))
							{
								cmd('$built/$file',null);
								break;
							}
						}
						continue;
					}
					cmd(built,[]);
				case 'java':
					var built = built;
					if (built == null) built = '$targetDir/java';
					if (isDirectory(built))
					{
						for (file in readDirectory(built))
						{
							if (file.endsWith('.jar'))
							{
								cmd('java',['-jar','$built/$file']);
								break;
							}
						}
						continue;
					}
					cmd('java',['-jar','$built']);
				case 'interp' | 'macro': // do nothing, already tested when building
			}
		}
	}

	static function build()
	{
		var flags = Sys.getEnv("HXFLAGS");
		if (flags == null)
			flags = "";
		var extra = Sys.getEnv("HXFLAGS_EXTRA");
		if (extra == null)
			extra = "";
		else
			extra = " " + extra;
		flags += extra;

		var flags = flags.split(' ');
		var targetDir = Sys.getEnv("TARGET_DIR");
		if (targetDir == null)
			targetDir = Sys.getCwd();
		for (target in Sys.getEnv("TARGET").split(" "))
		{
			var extra = Sys.getEnv("HXFLAGS_EXTRA");
			if (extra == null)
				extra = switch target
				{
					case 'neko':
						'-neko $targetDir/neko.n';
					case 'python':
						'-python $targetDir/python.py';
					case 'js':
						'-js $targetDir/js.js';
					case 'cpp' | 'java' | 'cs':
						'-$target $targetDir/$target';
					case 'interp':
						'--interp';
					case 'macro':
						Sys.getEnv("MACROFLAGS") == null ? "" : Sys.getEnv("MACROFLAGS");
					case _:
						trace("unkown target ", target);
						null;
				};
			if (extra != null)
				cmd('haxe',flags.concat(extra.split(' ')));
		}
	}

	static function setupHxcpp()
	{
		cmd('haxelib', ['git','hxcpp','https://github.com/HaxeFoundation/hxcpp'],3);
		cd('C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\project');
		cmd('neko', ['build.n']);
	}

	static function setup()
	{
		var toolkit = "C:\\HaxeToolkit";
		createDirectory('C:\\HaxeToolkit');
		// download neko
		download('http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/neko-latest-win.tar.gz', '$toolkit/neko.tar.gz');
		untar('$toolkit/neko.tar.gz', '$toolkit');
		for (file in readDirectory(toolkit))
		{
			if (file.startsWith('neko') && isDirectory('$toolkit/$file'))
			{
				rename('$toolkit/$file', '$toolkit/neko');
				break;
			}
		}

		// download haxe
		trace('download haxe');
		download('http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/windows/haxe_latest.tar.gz', '$toolkit/haxe.tar.gz');
		untar('$toolkit/haxe.tar.gz', '$toolkit');
		for (file in readDirectory(toolkit))
		{
			if (file.startsWith('haxe') && isDirectory('$toolkit/$file'))
			{
				rename('$toolkit/$file', '$toolkit/haxe');
				break;
			}
		}

		trace('setup haxelib');
		// setup haxelib
		createDirectory('$toolkit/haxe/lib');
		cmd('haxelib',['setup','$toolkit/haxe/lib']);

		cmd('haxe',[]); //check if it's installed correctly
		cmd('neko',['-version']);
		trace('configuring target');
		for (target in Sys.getEnv("TARGET").split(" "))
		{
			switch target
			{
				case 'cpp':
					setupHxcpp();
				case 'cs':
					cmd('haxelib', ['git','hxcs','https://github.com/HaxeFoundation/hxcs'],3);
				case 'java':
					cmd('haxelib', ['git','hxjava','https://github.com/HaxeFoundation/hxjava'],3);
					cmd('javac',['-version']);
			}
		}
	}

	static function download(url:String,target:String,?retry=3)
	{
		trace('[$retry]','download',url,target);
		do
		{
			var req = new haxe.Http(url);
			var err = null;
			req.onError = function(msg) err = msg;
			var out = sys.io.File.write(target);
			req.customRequest(false, out);
			out.close();
			if (err != null && retry <= 0)
				throw 'Cannot download $url : $err';
		} while (retry-- > 0);
	}

	static function untar(filename:String, target:String)
	{
		trace('untar',filename,target);
		var file = sys.io.File.read(filename);
		var gz = new format.gz.Reader(file);
		var out = new BytesOutput();
		gz.readHeader();
		gz.readData(out);
		var tar = new format.tar.Reader(new BytesInput(out.getBytes()));
		for (entry in tar.read())
		{
			createDirectory(target + '/' + Path.directory(entry.fileName));
			// trace(entry.fileName,entry.data.length,entry.fileSize);
			if (entry.data != null && entry.data.length > 0 && entry.fileSize > 0)
			{
				File.saveBytes( target + '/' + entry.fileName, entry.data );
			}
		}
	}

	static function cd(dir:String)
	{
		trace('cd',dir);
		Sys.setCwd(dir);
	}

	static function cmd(cmd:String,args:Array<String>,retry=0,throwOnError=true)
	{
		trace('[$retry,$throwOnError]',cmd,args == null ? "" :args.join(" "));
		if (cmd.startsWith('haxe'))
		{
			cmd = 'C:\\HaxeToolkit\\haxe\\' + cmd;
		} else if (cmd.startsWith('neko')) {
			cmd = 'C:\\HaxeToolkit\\neko\\' + cmd;
		}
		var ret = -1;
		do
		{
			ret = Sys.command(cmd,args);
			if (ret == 0 || ret < 0)
			{
				return 0;
			}
		} while(retry-- > 0);
		if (throwOnError)
			throw '$cmd response: $ret';
		return ret;
	}

}
