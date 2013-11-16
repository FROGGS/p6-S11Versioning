
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
                $unit := $loader.load_module($module_name, %opts, @GLOBALish, $line, $file);
                last if $unit;
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
    method locate_candidates($module_name, @prefixes, :$file) {
        my Mu $c := $p6ml.locate_candidates($module_name, nqp::p6listitems(nqp::decont([@prefixes])), :$file);
        $c[0] # we will only get one result
    }
    method load_setting($setting_name) { $p6ml.load_setting($setting_name) }
    method resolve_repossession_conflicts(@conflicts) { $p6ml.resolve_repossession_conflicts(@conflicts) }

    # methods exposed by Perl6::ModuleLoaderVMConfig
    method vm_search_paths() { $p6ml.vm_search_paths() }
    method find_setting($setting_name) { $p6ml.find_setting($setting_name) }
}

nqp::bindhllsym('perl6', 'ModuleLoader', MyModuleLoader);
