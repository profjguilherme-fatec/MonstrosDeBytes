package aprendizado;
import robocode.*;
import java.awt.Color;

// API help : https://robocode.sourceforge.io/docs/robocode/robocode/Robot.html

/**
 * PrimeiroRobo - a robot by (your name here)
 * Push para teste de webhook
 */
public class PrimeiroRobo extends Robot
{
	/**
	 * run: PrimeiroRobo's default behavior
	 */
	public void run() {
		setColors(Color.green,Color.green,Color.blue); // body,gun,radar
		// Robot main loop
		while(true) {
			// Evita ficar em cantos: se estiver perto de um canto, mova-se para o centro
			double margin = 80;
			double x = getX();
			double y = getY();
			double fieldWidth = getBattleFieldWidth();
			double fieldHeight = getBattleFieldHeight();
			if (x < margin || x > fieldWidth - margin || y < margin || y > fieldHeight - margin) {
				turnToAngle(90 + Math.random() * 180); // Vira para longe do canto
				ahead(150);
			}
			// Gira o radar constantemente para buscar inimigos
			turnRadarRight(360);
			// Movimento lateral para dificultar tiros
			turnRight(90);
			ahead(100 + Math.random() * 50);
		}
	// Gira para um ângulo absoluto
	public void turnToAngle(double angle) {
		double turn = angle - getHeading();
		while (turn < -180) turn += 360;
		while (turn > 180) turn -= 360;
		turnRight(turn);
	}
	}

	/**
	 * onScannedRobot: What to do when you see another robot
	 */
	public void onScannedRobot(ScannedRobotEvent e) {
		// Mira preditiva simples para inimigos parados
		double distance = e.getDistance();
		double firePower = 3.0;
		if (distance > 400) firePower = 1.0;
		else if (distance > 200) firePower = 2.0;
		// Predição simples: se o inimigo está quase parado, mire direto; se está se movendo, tente prever
		double enemyHeading = e.getHeading();
		double enemyVelocity = e.getVelocity();
		double bulletSpeed = 20 - 3 * firePower;
		double angleToEnemy = e.getBearing();
		double absBearing = getHeading() + angleToEnemy;
		double predictedX = getX() + distance * Math.sin(Math.toRadians(absBearing));
		double predictedY = getY() + distance * Math.cos(Math.toRadians(absBearing));
		// Se o inimigo está parado, atire direto
		if (Math.abs(enemyVelocity) < 0.1) {
			turnGunRight(angleToEnemy - getGunHeading() + getHeading());
		} else {
			// Predição simples para inimigos em movimento
			double time = distance / bulletSpeed;
			predictedX += enemyVelocity * time * Math.sin(Math.toRadians(enemyHeading));
			predictedY += enemyVelocity * time * Math.cos(Math.toRadians(enemyHeading));
			double dx = predictedX - getX();
			double dy = predictedY - getY();
			double theta = Math.toDegrees(Math.atan2(dx, dy));
			turnGunRight(theta - getGunHeading());
		}
		fire(firePower);
		// Movimento lateral (circling) ao redor do inimigo
		setTurnRight(angleToEnemy + 90);
		ahead(60);
	}

	/**
	 * onHitByBullet: What to do when you're hit by a bullet
	 */
	public void onHitByBullet(HitByBulletEvent e) {
		// Movimento evasivo ao ser atingido
		turnRight(90 - e.getBearing());
		ahead(100);
	}
	
	/**
	 * onHitWall: What to do when you hit a wall
	 */
	public void onHitWall(HitWallEvent e) {
		// Afasta-se rapidamente da parede
		back(100);
		turnRight(90);
	}	
}
