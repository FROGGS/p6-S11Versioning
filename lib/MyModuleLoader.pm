
class MyModuleLoader::Suggestions {
    method load_module($module_name, %opts, *@GLOBALish, :$line, :$file) {
        die "'$module_name' does not seem to be installed."
    }
}

BEGIN {
    class MyModuleLoader {
        my Mu $p6ml := nqp::gethllsym('perl6', 'ModuleLoader');
        my @loaders;

        method add_loader( $loader ) {
            @loaders.push: $loader
        }

        method load_module($module_name, %opts, *@GLOBALish, :$line, :$file) {
            my Mu $unit := try $p6ml.load_module($module_name, %opts, @GLOBALish, $line, $file);
            if $! {
                for @loaders -> $loader {
                    $loader.load_module($module_name, %opts, @GLOBALish, $line, $file)
                }
                nqp::hash()
            }
            else {
                $unit
            }
        }

        # methods exposed by Perl6::ModuleLoader
        method register_language_module_loader($lang, $loader) { $p6ml.register_language_module_loader($lang, $loader) }
        method register_absolute_path_func($func) { $p6ml.register_absolute_path_func($func) }
        method absolute_path($path) { $p6ml.absolute_path($path) }
        method ctxsave() { $p6ml.ctxsave() }
        method search_path() { $p6ml.search_path() }
        method locate_candidates($module_name, @prefixes, :$file) { $p6ml.locate_candidates($module_name, @prefixes, :$file) }
        method load_setting($setting_name) { $p6ml.load_setting($setting_name) }
        method resolve_repossession_conflicts(@conflicts) { $p6ml.resolve_repossession_conflicts(@conflicts) }

        # methods exposed by Perl6::ModuleLoaderVMConfig
        method vm_search_paths() { $p6ml.vm_search_paths() }
        method find_setting($setting_name) { $p6ml.find_setting($setting_name) }
    }

    MyModuleLoader.add_loader( MyModuleLoader::Suggestions );

    nqp::bindhllsym('perl6', 'ModuleLoader', MyModuleLoader);
}

=pod patch
diff --git a/src/Perl6/World.nqp b/src/Perl6/World.nqp
index 9e87f11..b85a61c 100644
--- a/src/Perl6/World.nqp
+++ b/src/Perl6/World.nqp
@@ -331,7 +331,7 @@ class Perl6::World is HLL::World {
     method load_module($/, $module_name, %opts, $cur_GLOBALish) {
         # Immediate loading.
         my $line   := HLL::Compiler.lineof($/.orig, $/.from, :cache(1));
-        my $module := Perl6::ModuleLoader.load_module($module_name, %opts,
+        my $module := nqp::gethllsym('perl6', 'ModuleLoader').load_module($module_name, %opts,
             $cur_GLOBALish, :$line);
         
         # During deserialization, ensure that we get this module loaded.
=cut patch
