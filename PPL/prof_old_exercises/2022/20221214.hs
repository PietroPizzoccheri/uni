import Control.Monad.State.Lazy  -- used for the Stack example


-- lolstream from the previous class
data LolStream a = LolStream Int [a]

isPeriodic :: LolStream a -> Bool
isPeriodic (LolStream n _) = n > 0

destream :: LolStream a -> [a]
destream (LolStream n l) = if n <= 0 then l else take n l

instance (Show a) => Show (LolStream a) where
    show l | not (isPeriodic l) = "LolStream[...]"
    show lol@(LolStream n l) = "LolStream" ++ show (destream lol) 

instance (Eq a) => Eq (LolStream a) where
    l1 == l2 = (destream l1) == (destream l2)

lolRepeat :: [a] -> [a]
lolRepeat l = l ++ lolRepeat l

lol2lolstream :: [[a]] -> LolStream a
lol2lolstream ls = LolStream (length ls') (lolRepeat ls') where
    ls' = concat ls
    
instance Functor LolStream where
    fmap f (LolStream n ls) = LolStream n (fmap f ls)

instance Foldable LolStream where
    -- foldr f z (LolStream _ ls) = foldr f z ls
    foldr f z ls = foldr f z (destream ls)

instance Applicative LolStream where
    pure x = lol2lolstream [[x]]
    lfs@(LolStream n fs) <*> lxs@(LolStream m xs) = if (n > 0) && (m > 0) then
        LolStream (n*m) (lolRepeat ((destream lfs) <*> (destream lxs)))
        else LolStream (-1) (fs <*> xs)

instance Monad LolStream where
    ls >>= fs =  lol2lolstream [(destream ls) >>= (\x -> destream (fs x))]
    
testM = do
    x <- lol2lolstream [[1..4]]
    y <- lol2lolstream [[2..5]]
    return (x,y)

--- stack
type Stack = [Int]

pop :: Stack -> (Stack, Int)
pop [] = error "Empty"
pop (x:xs) = (xs, x)

push :: Stack -> Int -> Stack
push xs x = (x:xs)

opsOnStack s0 =
    let (s1, _) = pop s0
        (s2, _) = pop s1
        s3 = push s2 100
        (s4, _) = pop s3
    in push s4 42

popM :: State Stack Int
popM = do
    stack <- get
    case stack of
        (x:xs) -> put xs >> return x
        [] -> error "Empty"

pushM :: Int -> State Stack ()
pushM x = do
    stack <- get
    put (x:stack)

stackMex = do
    popM
    popM
    pushM 100
    popM
    pushM 42






