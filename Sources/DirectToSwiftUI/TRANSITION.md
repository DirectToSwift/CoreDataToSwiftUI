# Transition TODOs

- Dynamic Member lookup
  - I think we can't add this to NSManagedObject? But do we
    need to? We have concrete classes? Hmm...

- NSManagedObject's are faults?

- snapshot in managed objects, how? (and where?)

- validation is builtin, can drop the own

- how to determine predicate complexity

- what about RulePredicate's, those cannot be used as qualifiers. We would
  need to wrap them.

- dropped `RuleClosurePredicate`

- AttributeValue things

- CD doesn't have (or need) primary/foreign keys!
  - the whole JoinTargetID story is superfluous
