HC      = ghc
HC_OPTS = -cpp -i/usr/lib/ghc/4.04/imports/exts 

SRCS = Haskore.hs IOExtensions.hs Basics.lhs GeneralMidi.lhs Performance.lhs HaskoreLoader.lhs Monads.hs Bitops.lhs HaskoreUtils.hs LoadMidi.lhs HaskToMidi.lhs MidiFile.lhs OutputMidi.lhs TestHaskore.lhs
OBJS = Haskore.o IOExtensions.o Basics.o GeneralMidi.o Performance.o HaskoreLoader.o Monads.o Bitops.o HaskoreUtils.o LoadMidi.o HaskToMidi.o MidiFile.o OutputMidi.o TestHaskore.o

.SUFFIXES : .o .hi .lhs .hc .s .hs

haskore.a: $(OBJS)
	rm -f haskore.a
	ar -q haskore.a $(OBJS) 

# Standard suffix rules
.o.hi:
	@:

.lhs.o:
	$(HC) -c $< $(HC_OPTS)

.hs.o:
	$(HC) -c $< $(HC_OPTS)

depend :
	ghc -M $(HC_OPTS) $(SRCS)

# DO NOT DELETE: Beginning of Haskell dependencies
Haskore.o : Haskore.hs
Haskore.o : ./HaskoreLoader.hi
IOExtensions.o : IOExtensions.hs
IOExtensions.o : /usr/lib/ghc/4.04/imports/exts/IOExts.hi
Basics.o : Basics.lhs
GeneralMidi.o : GeneralMidi.lhs
Performance.o : Performance.lhs
Performance.o : ./Basics.hi
HaskoreLoader.o : HaskoreLoader.lhs
HaskoreLoader.o : ./Basics.hi
HaskoreLoader.o : ./Performance.hi
HaskoreLoader.o : ./HaskToMidi.hi
HaskoreLoader.o : ./TestHaskore.hi
HaskoreLoader.o : ./ReadMidi.hi
Monads.o : Monads.hs
Bitops.o : Bitops.lhs
HaskoreUtils.o : HaskoreUtils.hs
LoadMidi.o : LoadMidi.lhs
LoadMidi.o : ./MidiFile.hi
LoadMidi.o : ./IOExtensions.hi
LoadMidi.o : ./Bitops.hi
LoadMidi.o : ./HaskoreUtils.hi
HaskToMidi.o : HaskToMidi.lhs
HaskToMidi.o : ./Basics.hi
HaskToMidi.o : ./Performance.hi
HaskToMidi.o : ./MidiFile.hi
HaskToMidi.o : ./GeneralMidi.hi
HaskToMidi.o : ./OutputMidi.hi
HaskToMidi.o : ./LoadMidi.hi
MidiFile.o : MidiFile.lhs
OutputMidi.o : OutputMidi.lhs
OutputMidi.o : ./MidiFile.hi
OutputMidi.o : ./IOExtensions.hi
OutputMidi.o : ./Monads.hi
OutputMidi.o : ./Bitops.hi
TestHaskore.o : TestHaskore.lhs
TestHaskore.o : ./Basics.hi
TestHaskore.o : ./Performance.hi
TestHaskore.o : ./HaskToMidi.hi
TestHaskore.o : ./GeneralMidi.hi
TestHaskore.o : ./OutputMidi.hi
# DO NOT DELETE: End of Haskell dependencies
