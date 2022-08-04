This requires `pack`.

1) Run:
```
pip install jupyter pandas vega
pip install --upgrade notebook
jupyter nbextension install --user --py vega
pip3 install vega==3.5
```

2) Make sure to have the following in your global `pack.toml` file (generally found under `~/.pack/user/pack.toml`:
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
