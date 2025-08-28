using Godot;
using System;

public partial class Player : CharacterBody2D
{
	// Constantes
	private const float SPEED = 50.0f;
	private const float JUMP_VELOCITY = -400.0f;

	// Acciones
	private bool RUN_ACTION;
	private bool JUMP_ACTION;
	private bool WALK_ACTION;
	private bool WALK_RIGHT;
	private bool WALK_LEFT;
	private bool CROUCH_ACTION;

	// Variables varias
	private Vector2 screenSize;
	private uint originalCollisionMask;

	public override void _Ready()
	{
		screenSize = GetViewportRect().Size;
		originalCollisionMask = CollisionMask;
	}

	public override void _Process(double delta)
	{
		// Actualizar acciones
		RUN_ACTION = Input.IsActionPressed("run");
		JUMP_ACTION = Input.IsActionPressed("jump");
		WALK_ACTION = Input.IsActionPressed("move_left") || Input.IsActionPressed("move_right");
		WALK_RIGHT = Input.IsActionPressed("move_right");
		WALK_LEFT = Input.IsActionPressed("move_left");
		CROUCH_ACTION = Input.IsActionPressed("crouch");

		var sprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");

		// Animaciones
		sprite.Play();
		sprite.FlipV = false;
		sprite.FlipH = Velocity.X < 0;

		// Movimiento con animaciones
		if (Velocity.X != 0)
		{
			if (RUN_ACTION)
			{
				if (JUMP_ACTION && !IsOnFloor())
					sprite.Animation = "jump";
				else
					sprite.Animation = "run";
			}
			else if (WALK_ACTION)
			{
				if (CROUCH_ACTION)
					sprite.Animation = "crouch_walk";
				else if (JUMP_ACTION && !IsOnFloor())
					sprite.Animation = "jump";
				else
					sprite.Animation = "walk";
			}
		}
		else // Idle
		{
			if (CROUCH_ACTION)
				sprite.Animation = "crouch_idle";
			else if (JUMP_ACTION && !IsOnFloor())
				sprite.Animation = "jump";
			else
				sprite.Animation = "idle";
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		// Gravedad
		if (!IsOnFloor())
			Velocity += GetGravity() * (float)delta;

		// Saltos
		if (Input.IsActionJustPressed("jump") && IsOnFloor())
		{
			if (Input.IsActionPressed("crouch"))
				Velocity = new Vector2(Velocity.X, 0.65f * JUMP_VELOCITY);
			else if (Input.IsActionPressed("run"))
				Velocity = new Vector2(Velocity.X, 1.15f * JUMP_VELOCITY);
			else
				Velocity = new Vector2(Velocity.X, JUMP_VELOCITY);
		}

		// Movimiento lateral
		float direction = Input.GetAxis("move_left", "move_right");
		if (direction != 0)
		{
			if (Input.IsActionPressed("run"))
				Velocity = new Vector2(direction * 3 * SPEED, Velocity.Y);
			else
				Velocity = new Vector2(direction * SPEED, Velocity.Y);
		}
		else
		{
			Velocity = new Vector2(Mathf.MoveToward(Velocity.X, 0, SPEED), Velocity.Y);
		}

		// Caída de plataformas
		if (IsOnPlatform() && Input.IsActionJustPressed("crouch"))
			CollisionMask &= 1;

		if (!Input.IsActionPressed("crouch") && CollisionMask != originalCollisionMask)
			CollisionMask = originalCollisionMask;

		MoveAndSlide();
	}

	private bool IsOnPlatform()
	{
		// En tu caso los "plataformas" tienen máscara 3
		return IsOnFloor() && CollisionMask == 3;
	}
}
