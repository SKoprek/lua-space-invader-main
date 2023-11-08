--  player 150x60
--  enemy 120x60
screen_width = love.graphics.getWidth()
screen_height = love.graphics.getHeight()
image_scale = 0.3

player = {}
player_width = 120
player_height = 60
player.x = (screen_width / 2) - (player_width / 2)
player.y = 200
player.score = 0
-- enemy_counter = 7
enemy = {}
enemy_width = 120
enemy_height = 60
enemy_direction = 0
-- enemy.x=
enemy_animation_tick = 60

enemies_list = {}

bullets = {}
bullets_generation_tick = 30

enemy_bullets = {}
enemies_bullets_generation_tick = 1

function player:shoot()
	if bullets_generation_tick <= 0 then
		bullets_generation_tick = 30
		bullet = {}
		bullet.x = player.x + ((player_width / 2) * image_scale)
		bullet.y = 520
		table.insert(bullets, bullet)
		love.audio.play(player_shoot_sound)
	end
end

function enemy:spawn()
		enemy_counter = math.random(5,15)
		print("Spawn Enemy: ",enemy_counter)
		for i_enemy = 1, enemy_counter do
			local enemy={}
			enemy.image = love.graphics.newImage('images/invader.png')
			enemy.x = (screen_width / ((enemy_counter - (enemy_counter % 2)) / 2)) + (70 * (i_enemy % 5))
			enemy.y = screen_height / 2 - (30 * (i_enemy % 3))
			print("Enemy: ",i_enemy, " - ", enemy.x, " : ",enemy.y)
			table.insert(enemies_list, enemy)
		end
end

function enemy:shoot()
	if enemies_bullets_generation_tick <= 0 then
		local nextSE = math.random(50,360)
		enemies_bullets_generation_tick = nextSE
		enemy_bullet = {}
		if next(enemies_list) then
			local count = 0
			for _ in pairs(enemies_list) do count = count + 1 end
			local enemy_index = math.random(1,count)
			enemy_bullet.x = enemies_list[enemy_index].x + ((enemy_width / 2) * image_scale)
			enemy_bullet.y = enemies_list[enemy_index].y
			table.insert(enemy_bullets, enemy_bullet)
			-- love.audio.play(player_shoot_sound)
			-- print("Nex bulet at: ",nextSE)
		end
	end
end

function enemy:animation()	
	if enemy_animation_tick <= 0 then
		enemy_animation_tick = 60
		local enemy_min_width = screen_width + 1
		local enemy_max_width = -1
		for _, enemy in pairs(enemies_list) do 
			if enemy.x < enemy_min_width then
				enemy_min_width = enemy.x
			end
			if enemy.x > enemy_max_width then
				enemy_max_width = enemy.x
			end
		end
		if enemy_min_width > enemy_width + 20 or enemy_max_width < screen_width - enemy_width + 20 then
			local random = math.random(-1,1)
			enemy_direction = random
		elseif enemy_min_width > enemy_width + 20 then
			enemy_direction = 1
		elseif enemy_max_width < screen_width - enemy_width + 20 then
			enemy_direction = -1
		else
			enemy_direction = 0
		end
		
	end
end

function bulletCollisions(enemies_list, bullets)
	for xa, enemyC in pairs(enemies_list)do
		for xb, bulletC in pairs(bullets) do
			if bulletC.y <= (enemyC.y + (enemy_height * image_scale)) and bulletC.x > enemyC.x and bulletC.x < (enemyC.x + (enemy_width * image_scale)) then
				-- print(bulletC.x," : ",enemyC.x)
				-- print(enemyC.x + enemy_width * image_scale)
				table.remove(enemies_list, xa)
				table.remove(bullets, xb)
				player.score = player.score + 10
			end
		end
	end
end

function enemyBulletCollisions(enemy_bullets)
	for xt, bulletE in pairs(enemy_bullets) do
		-- print(bulletE.x," : HIT PLAYER : ",player.x)
		if bulletE.y >= 580 and bulletE.x > player.x and bulletE.x < (player.x + (player_height)) then
			print(" : HIT PLAYER : ")
			print("BULET y : ",bulletE.y," | PLAYER y : ",screen_height - player.y)
			table.remove(enemy_bullets, xt)
			player.score = player.score - 50

		end
	end
end

-- ############
function love.load()
	print("SCREEN WIDTH: ",screen_width," | SCREEN HEIGHT: ",screen_height)
	player.image = love.graphics.newImage('images/player.png')
	player.explose_shoot = love.audio.newSource('sounds/shoot.mp3','static')
	enemy.image = love.graphics.newImage('images/invader.png')
	music = love.audio.newSource('sounds/music.mp3','static')
	player_shoot_sound = love.audio.newSource('sounds/shoot.mp3','static')
	music:setLooping(true)
	-- love.audio.play(music)
	enemy.spawn()
end

function love.draw()
	love.graphics.print("Space Invaders Example",2 , 10)
	love.graphics.print(string.format("HIGHT SCORE: %s", player.score) ,screen_width / 2, 15)
	love.graphics.setColor(1,1,1)
    for it, bullet in pairs(bullets) do
		love.graphics.rectangle("fill",bullet.x, bullet.y, 5,20)
	end
    for it, enemy_bullet in pairs(enemy_bullets) do
		love.graphics.rectangle("line",enemy_bullet.x, enemy_bullet.y, 5,20)
	end
	love.graphics.draw(player.image, player.x, 580, 0, image_scale)
	for _, e in pairs(enemies_list) do
		love.graphics.draw(e.image, e.x, e.y, 0, image_scale )
	end
end

function love.update()
	if love.keyboard.isDown('right') then
		if player.x > 750 then
			player.x = 750
		end
		-- print("Right key pressed")
		player.x = player.x + 5
	end
	if love.keyboard.isDown('left') then
		if player.x  < 10 then
			player.x = 10
		end
		-- print("Left key pressed")
		player.x = player.x - 5
	end
	if love.keyboard.isDown('space') then
		player.shoot()
	end
	if love.keyboard.isDown('q') then
		love.event.quit()
	end

	for it, enemy in pairs(enemies_list) do
		if enemy_animation_tick <= 0 then
			enemy.x = enemy.x + (enemy_direction * 20)
		end
	end

	for it, bullet in pairs(bullets) do
		if (bullet.y>0) then
			table.remove(enemy_bullets,it)
		end
		bullet.y = bullet.y - 5
	end

	for ib, enemy_bullet in pairs(enemy_bullets) do
		if (enemy_bullet.y>screen_height) then
		table.remove(enemy_bullets,ib)
		end
		enemy_bullet.y = enemy_bullet.y + 5
	end
	if next(enemies_list) == nil then
		enemy.spawn()
	end

	enemy.animation()

	bullets_generation_tick = bullets_generation_tick - 1
	enemies_bullets_generation_tick = enemies_bullets_generation_tick - 1
	enemy_animation_tick = enemy_animation_tick - 1
	enemy.shoot()
	bulletCollisions(enemies_list, bullets)
	enemyBulletCollisions(enemy_bullets)
end
