# CNVKit Demo

Aplikacja demonstrująca działanie biblioteki CNVKit (http://cnvkit.readthedocs.io/en/stable/cnvlib.html).

### Struktura

Repozytorium zawiera dwa podfoldery:

* cnvkit_demo - kod źródłowy aplikacji
* external_tools - zewnętrzne narzędzia binarne do pracy z danymi wykorzystane podczas realizacji projektu

### Uruchomienie

Aplikacja jest wykonana w języku python 3.6 i wymaga następujących pakietów:

* PyQt5
* cnvlib

Zainstalować je można wydając polecenie:

```shell
pip3 install [PyQt5/cnvlib]
```

Następnie będąc w katalogu głównym uruchamiamy program wydając polecenie:

```shell
PYTHONPATH=`pwd` python3 cnvkit_demo/CNVKitDemo.py
```




