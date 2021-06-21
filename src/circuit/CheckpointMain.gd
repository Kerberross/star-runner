extends Checkpoint

func on_body_entered(body: Node):
	if body is AbstractShip and body.next_checkpoint == self:
		body.lap += 1
	.on_body_entered(body)
