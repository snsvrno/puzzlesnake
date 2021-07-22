package core;

class Macros {
    public static macro function getGitCommitHash(?length:Int):haxe.macro.Expr.ExprOf<String> {
      #if !display
      var process = new sys.io.Process('git', ['rev-parse', 'HEAD']);
      if (process.exitCode() != 0) {
        var message = process.stderr.readAll().toString();
        var pos = haxe.macro.Context.currentPos();
        haxe.macro.Context.error("Cannot execute `git rev-parse HEAD`. " + message, pos);
      }
      
      // read the output of the process
      var commitHash:String = process.stdout.readLine();
      if (length != null) commitHash = commitHash.substr(0,length);
      
      // Generates a string expression
      return macro $v{commitHash};
      #else 
      // `#if display` is used for code completion. In this case returning an
      // empty string is good enough; We don't want to call git on every hint.
      var commitHash:String = "";
      return macro $v{commitHash};
      #end
    }

    public static macro function getDate():haxe.macro.Expr.ExprOf<String>  {
        #if !display
        var date : String = DateTools.format(Date.now(),"%Y%m%d-%H%M%S");
        // Generates a string expression
        return macro $v{date};
        #else 
        // `#if display` is used for code completion. In this case returning an
        // empty string is good enough; We don't want to call git on every hint.
        var date:String = "";
        return macro $v{date};
        #end

    } 

    public static macro function getVersionTag() : haxe.macro.Expr.ExprOf<String> {
        #if !display
        var process = new sys.io.Process('git', ['tag', '--sort=taggerdate']);
        if (process.exitCode() != 0) {
          var message = process.stderr.readAll().toString();
          var pos = haxe.macro.Context.currentPos();
          haxe.macro.Context.error("Cannot execute `git tag --sort=taggerdate`. " + message, pos);
        }
        
        // read the output of the process
        var version:String = " ";
        try {
            while(version.length > 0 && version.substr(0,1) != 'v') version = process.stdout.readLine();
            if (version.length > 0) version = version.substr(1);
        } catch (e) { 
            version = "_._._"; 
        }

        // Generates a string expression
        return macro $v{version};
        #else 
        // `#if display` is used for code completion. In this case returning an
        // empty string is good enough; We don't want to call git on every hint.
        var version:String = "";
        return macro $v{version};
        #end
    }
  }