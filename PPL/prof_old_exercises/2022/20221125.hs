-- Logger monad
type Log = [String]
data Logger a = Logger a Log

instance (Eq a) => Eq (Logger a) where
    (Logger x _) == (Logger y _) = x == y

instance (Show a) => Show (Logger a) where
    show (Logger d l) = show d 
        ++ "\nLog:" ++
        foldr (\line acc-> "\n\t" ++ line ++ acc) "" l

instance Functor Logger where
    fmap f (Logger x l) = Logger (f x) l

instance Applicative Logger where
    pure x = Logger x [] -- return
    (Logger f fl) <*> (Logger x xl) = Logger (f x) (fl ++ xl)

instance Monad Logger where
    (Logger x l) >>= f = 
        let Logger x' l' = f x
        in  Logger x' (l ++ l')

putLog :: String -> Logger ()
putLog s = Logger () [s]


-- Binary trees
data BTree a = BEmpty | BNode a (BTree a) (BTree a) deriving Eq
bleaf x = BNode x BEmpty BEmpty

instance Show a => Show (BTree a) where
    show BEmpty = ""
    show (BNode v x y) = "<" ++ show x ++ " " ++ show v ++ " " ++ show y ++ ">" 

t1 = BNode 1 (bleaf 2) (BNode 3 (bleaf 4) (bleaf 5))
t2 = BNode 2 (BNode 2 (bleaf 3) (bleaf 2)) (bleaf 5)

bleafM x = do
    putLog $ "Created leaf " ++ show x
    return $ bleaf x

treeReplaceM :: (Eq a, Show a) => BTree a -> a -> a -> Logger (BTree a)
treeReplaceM BEmpty _ _ = return BEmpty
treeReplaceM (BNode v l r) x y = do
    newl <- treeReplaceM l x y
    newr <- treeReplaceM r x y
    if v == x then do 
        putLog $ "replaced " ++ show x ++ " with " ++ show y
        return $ BNode y newl newr 
    else
        return $ BNode v newl newr

buildTreeM :: Int -> Logger (BTree Int)
buildTreeM 0 = bleafM 0
buildTreeM x = do
    putLog $ "Added node " ++ show x
    l <- buildTreeM (x `div` 2)
    r <- buildTreeM (x `div` 2)
    return $ BNode x l r

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

-- instance Applicative LolStream where
--     pure x = lol2lolstream [[x]]
--     (LolStream n fs) <*> (LolStream m xs) = ???
