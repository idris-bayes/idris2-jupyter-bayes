This requires `pack`.

1) Run:
```
pip install jupyter pandas vega
pip install --upgrade notebook
jupyter nbextension install --user --py vega
pip3 install vega==3.5
```

2) Make sure to have the following in your global `pack.toml` file (generally found under `~/.pack/user/pack.toml`):
```
[custom.all.json-schema]
type   = "github"
url    = "https://github.com/madman-bob/idris2-json-schema"
commit = "latest:main"
ipkg   = "json-schema.ipkg"
```

3) Change to the directory `run` of this repository and run the shell script:
```
cd run
./jupyter_run.sh
```

4) In the browser, go to the jupyter notebook and select `idris2`.

5) The dependencies of the notebook are given in `dummy.ipkg`, an `.ipkg` file which will be read by Idris when invoked by the jupyter kernel. This file must list all necessary dependencies, including the one to `bayes`, otherwise we won't be able to run `:module LinRegr`.
