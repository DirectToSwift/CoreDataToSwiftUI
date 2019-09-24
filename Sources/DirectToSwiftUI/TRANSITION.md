# Transition TODOs

- Dynamic Member lookup
  - I think we can't add this to NSManagedObject? But do we
    need to? We have concrete classes? Hmm...

- NSManagedObject's are faults?

- snapshot in managed objects, how? (and where?)

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

- entity name is optional in CD

- we might need to sort access to relationsships/attributesByName
