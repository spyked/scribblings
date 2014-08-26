class MyClass a where
  myMethod :: a -> Int

instance MyClass Int where
  myMethod = (+ 1) . fromIntegral
