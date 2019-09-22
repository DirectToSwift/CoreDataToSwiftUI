# Transition TODOs

- all key/value coding things
  - RuleKeyPathAssignment
    - how to do KVC against the rule context? Just define an own imp?
      - it already has that, we just also need the builtin KVC names
    => figure out the renaming required (keypathes, plain pathes)
    
- validation is builtin, can drop the own

- global IDs
  - the managed gid is different, maybe a subclass?

- display group
  - needs to be rebuild completely

- rename the database environment key (we use it for the MOC right now)

- how to determine predicate complexity

- what about RulePredicate's, those cannot be used as qualifiers. We would
  need to wrap them.

- dropped `RuleClosurePredicate`

- there is no QualifierEvaluation protocol, all predicates can do that

- AttributeValue things

- CD doesn't have (or need) primary/foreign keys!
  - the whole JoinTargetID story is superfluous
