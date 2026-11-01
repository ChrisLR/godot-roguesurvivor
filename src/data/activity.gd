class_name Activity
## Port of Data/Activity.cs
## Anonymous enum so members are direct constants (C# call sites: Activity.CHASING).
enum {
	## Doing nothing in particular.
	IDLE,

	## Chasing an enemy.
	CHASING,

	## Fighting an enemy.
	FIGHTING,

	## Following a track.
	TRACKING,

	## Fleeing from a danger/enemy.
	FLEEING,

	## Following another actor.
	FOLLOWING,

	## zzzZZZzzz...
	SLEEPING,

	## Following an order.
	FOLLOWING_ORDER,

	## Fleeing from a primed explosive.
	FLEEING_FROM_EXPLOSIVE
}
