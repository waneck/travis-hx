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
		}
	}

	static function setup()
	{
		var home = Sys.getEnv("HOME");
		if (home == null)
		{
			trace('home is null');
			home = Sys.getEnv("HOMEPATH");
		}
		if (home == null)
		{
			trace('home is still null');
			home = 'C:\\HaxeToolkit';
		}
		var toolkit = "C:\\HaxeToolkit";
		createDirectory('C:\\HaxeToolkit');
		// download neko
		//todo
		// download haxe
		trace('download haxe');
		download('http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/windows/haxe_latest.tar.gz', '$toolkit/haxe.tar.gz');
		untar('$toolkit/haxe.tar.gz', '$toolkit');
		trace(readDirectory('$toolkit'));
		for (file in readDirectory(toolkit))
		{
			if (file.startsWith('haxe') && isDirectory('$toolkit/$file'))
			{
				rename('$toolkit/$file', '$toolkit/haxe');
				break;
			}
		}
		trace(readDirectory('$toolkit'));
		trace(readDirectory('$toolkit/haxe'));
		trace(Sys.environment());

		trace('setup haxelib');
		// setup haxelib
		createDirectory('$home/haxelib');
		cmd('haxelib',['setup','$home/haxelib']);

		cmd('haxe',[]); //check if it's installed correctly
		trace('configuring target');
		for (target in Sys.getEnv("TARGET").split(" "))
		{
			switch target
			{
				case 'cpp':
					cmd('haxelib', ['git','hxcpp','https://github.com/HaxeFoundation/hxcpp'],3);
					cd('$home/haxelib/hxcpp/git/project');
					cmd('neko', ['build.n']);
				case 'cs':
					cmd('haxelib', ['git','hxcs','https://github.com/HaxeFoundation/hxcs'],3);
				case 'java':
					cmd('haxelib', ['git','hxjava','https://github.com/HaxeFoundation/hxjava'],3);
					cmd('javac',['--version']);
			}
		}
	}

	static function download(url:String,target:String,?retry=3)
	{
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
		var file = sys.io.File.read(filename);
		var gz = new format.gz.Reader(file);
		var out = new BytesOutput();
		gz.readHeader();
		gz.readData(out);
		var tar = new format.tar.Reader(new BytesInput(out.getBytes()));
		for (entry in tar.read())
		{
			createDirectory(target + '/' + Path.directory(entry.fileName));
			trace(entry.fileName,entry.data.length,entry.fileSize);
			if (entry.data != null && entry.data.length > 0 && entry.fileSize > 0)
			{
				File.saveBytes( target + '/' + entry.fileName, entry.data );
			}
		}
	}

	static function cd(dir:String)
	{
		Sys.setCwd(dir);
	}

	static function cmd(cmd:String,args:Array<String>,retry=0,throwOnError=true)
	{
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
			if (ret == 0)
			{
				return 0;
			}
		} while(retry-- > 0);
		if (throwOnError)
			throw '$cmd response: $ret';
		return ret;
	}

}
