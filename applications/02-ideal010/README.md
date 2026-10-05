# Ideal 010: first embodied interaction loop

This is a target-side counterpart to Ideal's first embodied-paradigm example. It is not a conventional reward-maximizing reinforcement-learning agent. Each cycle starts with an initiated experiment and ends with the result produced by that experiment.

| Ideal concept | M6x09-I representation |
| --- | --- |
| Experiment `E1` | Write `$01` to GPIO1. |
| Experiment `E2` | Write `$02` to GPIO1. |
| Result `R1` | The local deterministic environment returns `$01` for E1. |
| Result `R2` | The local deterministic environment returns `$02` for E2. |
| Interaction | A recorded `<experiment, result>` pair held in RAM. |
| Anticipation | One stored result prediction for each experiment. |
| Mood | `F` frustrated, `S` self-satisfied, or `B` bored. |

Run `$0200` after loading. The terminal should produce this trace, with the cycle digit in hexadecimal:

```text
C0 e1r1 F
C1 e1r1 S
C2 e1r1 S
C3 e1r1 S
C4 e1r1 B
C5 e2r2 F
C6 e2r2 S
C7 e2r2 S
C8 e2r2 S
C9 e2r2 B
CA e1r1 S
```

GPIO1 displays `$01` for E1 and `$02` for E2. This makes initiated experiments physically visible while keeping the environment deterministic and debuggable.

## Limits and next experiment

The result function is deliberately inside this first binary. That corresponds to Ideal's minimal environment and validates the interaction architecture before a sensor is introduced. The next experiment should replace `Result = Experiment + 1` with a result from an external signal—initially a GPIO input or a serially mediated physical apparatus—while preserving the same trace and interaction-memory format.
