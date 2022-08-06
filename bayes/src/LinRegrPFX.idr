||| Linear regression using ProbFX
module LinRegrPFX

import Data.List
import Data.List.Elem
import ProbFX.Env
import ProbFX.Sampler
import ProbFX.Model
import ProbFX.Inference.SIM
import ProbFX.Inference.LW
import ProbFX.Inference.MH
import ProbFX.Effects.Lift

||| Linear regression environment
public export
LinRegrEnv : List (String, Type)
LinRegrEnv = map ((, Double)) ["mu", "c", "std", "y"]

||| Linear regression model
export
linRegr : (prf : Observables env ["y", "mu", "c", "std"] Double) => List Double -> Model env es (List Double)
linRegr xs = do
  mu  <- normal 0 3 "mu"
  c   <- normal 0 5 "c"
  std <- uniform 1 3 "std"
  ys  <- sequence $ map (\x => do
                    y <- normal (mu * x + c) std "y"
                    pure y) xs
  pure ys

||| An environment that sets the gradient mu = 3, intercept c = 0, and noise std = 1
export
envExampleSim : Env LinRegrEnv
envExampleSim = ("mu" ::= [3]) <:> ("c" ::= [0]) <:> ("std" ::=  [1]) <:> ("y" ::=  []) <:> ENil

||| An environment for inference whose data represents the gradient m = 3 and intercept c = 0
export
envExampleInf : List Double -> Env LinRegrEnv
envExampleInf xs =
  let ys = map (*3) xs
  in  ("mu" ::= []) <:> ("c" ::= []) <:> ("std" ::=  []) <:> ("y" ::=  ys) <:> ENil

||| Linear regression as a probabilistic program
hdlLinRegr : Prog (Observe :: Sample :: []) (List Double, Env LinRegrEnv)
hdlLinRegr = handleCore envExampleSim (linRegr [])

||| Simulating linear regression, using effect handlers
export
simLinRegr : (n_datapoints : Nat) -> IO (List (Double, Double))
simLinRegr n_datapoints = do
  let xs = map cast [0 .. n_datapoints]
  (ys, env_out) <- simulate (linRegr xs) envExampleSim
  pure (zip xs ys)

||| LW inference on linear regression, using effect handlers
export
lwLinRegr : (n_lwiterations : Nat) -> (n_datapoints : Nat) -> IO (List (Double, Double))
lwLinRegr n_lwiterations n_datapoints = do
  let xs = map cast [0 .. n_datapoints]
  (envs_out, ws) <- unzip <$> (lw n_lwiterations (linRegr xs) (envExampleInf xs))
  let mus : List Double = gets "mu" envs_out
  pure (zip mus ws)

||| MH inference on linear regression, using effect handlers
export
mhLinRegr : (n_mhsteps : Nat) -> (n_datapoints : Nat) -> IO (List Double, List Double)
mhLinRegr n_mhsteps n_datapoints = do
  let xs = map cast [0 .. n_datapoints]
  envs_out <- mh n_mhsteps (linRegr xs) (envExampleInf xs)
  let mus : List Double = gets "mu" envs_out
      cs  : List Double = gets "c" envs_out
  pure (mus, cs)
