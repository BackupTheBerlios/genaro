module PatronesRitmicos
where

import Haskore
import Ratio
import PrologAHaskell

--
-- PATRON RITMICO
--
-- se tienen en cuenta los ligados
type Voz = Int
type Acento = Float
type Ligado = Bool
type UPR = [(Voz, Acento, Ligado, Dur)]
type PatronRitmico = [UPR]
