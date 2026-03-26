data Expr
  = VarX
  | VarY
  | Sine    Expr
  | Cosine  Expr
  | Average Expr Expr
  | Times   Expr Expr
  | Thresh  Expr Expr Expr Expr

-- AST of "cos(pi*x*y)"
expr1 :: Expr
expr1 = Cosine (Times VarX VarY)

-- AST of "sin(pi*(cos(pi*x)*y))"
expr2 :: Expr
expr2 = Sine (Times (Cosine VarX) VarY)

-- pretty-printed string of `Sine (Times (Cosine VarX) VarY)`
str1 :: String
str1 = "sin(pi*cos(pi*x)*y)"

-- pretty-printed string of `Average (Sine (Times VarX VarY)) (Cosine (Average VarX VarY))`
str2 :: String
str2 = "((sin(pi*x*y)+cos(pi*((x+y)/2)))/2)"

depth :: Expr -> Int
depth VarX = 0
depth VarY = 0
depth (Sine e) = 1 + depth e
depth (Cosine e) = 1 + depth e
depth (Average e1 e2) = 1 + max (depth e1) (depth e2)
depth (Times e1 e2) = 1 + max (depth e1) (depth e2)
depth (Thresh e1 e2 e3 e4) = 1 + max (max (depth e1) (depth e2)) (max (depth e3) (depth e4))
-- Can you think of a nicer way to write the `Thresh` case with a higher-order function?

-- AST of "((x+y)/2)*cos(pi*sin(pi*y))"
myExpr :: Expr
myExpr = Times (Average VarX VarY) (Cosine (Sine VarY))

-- depth myExpr == 3
