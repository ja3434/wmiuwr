# Lista 1
###### tags: `so-rozw`

## Zadanie 1

<!-- ::: -->
> W systemach uniksowych wszystkie procesy są związane relacją **rodzic-dziecko**. Uruchom polecenie `ps -eo user,pid,ppid,pgid,tid,pri,stat,wchan,cmd`. Na wydruku zidentyfikuj **identyfikator procesu**, **identyfikator grupy procesów**, **identyfikator rodzica** oraz **właściciela** procesu. Kto jest rodzicem procesu $\texttt{init}$? Wskaż, które z wyświetlonych zadań są **wątkami jądra**. Jakie jest znaczenie poszczególnych znaków w kolumnie STAT? Wyświetl drzewiastą reprezentację **hierarchii procesów** poleceniem pstree – które z zadań są wątkami?
<!-- ::: -->

### Definicje

**Relacja rodzic-dziecko** - Jeżeli proces używje wywołania systemowego `fork`, to jądro systemu operacyjnego tworzy identyczną kopię tego procesu. Tę kopię nazywamy *dzieckiem*, a proces wołający `fork` nazywamy *rodzicem*. Jeśli proces rodzica umrze, a proces dziecka nie, to rodzicem dziecka staje się rodzic jego rodzica (*reparenting*).

**Identyfikator procesu (PID)** - unikalny numer, który jądro przypisuje danemu procesowi w momencie jego powstawania.

**Identyfikator grupy procesów** - #TODO

**Identyikator rodzica (PPID)** - (w kontekście jakiegoś konkretnego procesu) PID rodzica procesu.

**Wątki jądra** - #TODO

**Hierarchia procesów** - Graf skierowany, którego wierzchołkami są procesy, a krawędzie są dane przez relację rodzic-dziecko.

> Kto jest rodzicem procesu $\texttt{init}$? 


> Jakie jest znaczenie poszczególnych znaków w kolumnie STAT?
```
PROCESS STATE CODES
       Here are the different values that the s, stat and state output specifiers (header "STAT" or "S") will display to describe the state of a process:

               D    uninterruptible sleep (usually IO)
               I    Idle kernel thread
               R    running or runnable (on run queue)
               S    interruptible sleep (waiting for an event to complete)
               T    stopped by job control signal
               t    stopped by debugger during the tracing
               W    paging (not valid since the 2.6.xx kernel)
               X    dead (should never be seen)
               Z    defunct ("zombie") process, terminated but not reaped by its parent

       For BSD formats and when the stat keyword is used, additional characters may be displayed:

               <    high-priority (not nice to other users)
               N    low-priority (nice to other users)
               L    has pages locked into memory (for real-time and custom IO)
               s    is a session leader
               l    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)
               +    is in the foreground process group
```


## Zadanie 2
> Jak jądro systemu reaguje na sytuację kiedy proces staje się **sierotą**? W jaki sposób pogrzebać proces, który wszedł w stan **zombie**? Czemu proces nie może sam siebie pogrzebać? Zauważ, że proces może, przy pomocy `waitpid(2)`, czekać na zmianę **stanu** wyłącznie swoich dzieci. Co złego mogłoby się stać, gdyby znieść to ograniczenie? Rozważ scenariusze (a) dziecko może czekać na zmianę stanu swojego rodzica (b) wiele procesów oczekuje na zmianę stanu jednego procesu.

> Jak jądro systemu reaguje na sytuację kiedy proces staje się **sierotą**?

**Sierotą** nazywamy proces, którego proces rodzica został zakończony. Takie procesy są podpinane jako dzieci procesu 1 `init` (reparenting).

> W jaki sposób pogrzebać proces, który wszedł w stan **zombie**?

**Zombie** to określenie procesu, który zakończył swoje działanie, ale nie został "pogrzebany" przez swojego rodzica. Grzebania można dokonać przy pomocy wywołania systemowego `wait`. Czemu procesy przechodzą w stan zombie, zamiast po prostu umrzeć? Np. dlatego, żeby proces rodzica mógł dostać status wyjścia tego zmarłego procesu.

Z `man wait`: 
> A child that terminates, but has not been waited for becomes a "zom‐
       bie".  The kernel maintains a minimal set of information  about  the
       zombie process (PID, termination status, resource usage information)
       in order to allow the parent to later perform a wait to  obtain  in‐
       formation  about the child.  As long as a zombie is not removed from
       the system via a wait, it will consume a slot in the kernel  process
       table,  and  if  this table fills, it will not be possible to create
       further processes.  If a parent process terminates, then  its  "zom‐
       bie"  children  (if  any) are adopted by init(1), (or by the nearest
       "subreaper" process as defined  through  the  use  of  the  prctl(2)
       PR_SET_CHILD_SUBREAPER  operation); init(1) automatically performs a
       wait to remove the zombies.

> Czemu proces nie może sam siebie pogrzebać?

Skoro proces zakończył działanie, to nie dokonuje już żadnych operacji. Poza tym, to byłoby bezcelowe, powód dlaczego w ogóle chcemy grzebać opisałem wyżej.



## Zadanie 8
Rozwiązanie w katalogu niżej, het.c

Diagram procesów: # TODO