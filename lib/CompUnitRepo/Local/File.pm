
class CompUnitRepo::Local::File is export {
    has @!paths;
    method new( *@location ) {
        self.bless(:@location)
    }

    method BUILD( :@location ) {
        @!paths = @location;
        self
    }

    method install( $source, $from? ) {
        ...
    }

    method candidates( $longname, :$file, :$auth, :$ver ) {
        my @candi;
        my Mu $c := nqp::gethllsym('perl6', 'ModuleLoader').p6ml.locate_candidates($longname, nqp::p6listitems(nqp::decont([@!paths])), :$file);
        if $c[0] {
            $c[0]<ver> = Version.new( '*' );
            @candi.push: $c[0].item;
        }
        @candi
    }
}
