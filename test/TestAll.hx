package;

import hxUri.TestParams;
import hxUri.TestResolve;
import hxUri.Uri;

import utest.Runner;
import utest.ui.Report;

class TestAll {
	static public function main():Void {
		
		var runner = new Runner();
		
		runner.addCase(new TestParams());
		runner.addCase(new TestResolve());
		
		Report.create(runner);
		runner.run();
		
	#if flash
		flash.system.System.exit(1);
	#end
	}
}