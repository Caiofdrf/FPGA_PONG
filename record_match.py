import pygame

# Configurações iniciais do Pygame
pygame.init()
screen = pygame.display.set_mode((512, 256))
clock = pygame.time.Clock()
running = True

# --- CONSTANTES VINDAS DO VERILOG ---
BAIXO = 0
PARADO = 1
CIMA = 2

VAR_VEL = 2
PLAYER_VEL = 5
PLAYER_MID_LENGHT = 24
SCREEN_TOP = 25
SCREEN_BOTTOM = 231
SCREEN_W = 512

# --- VARIÁVEIS DE ESTADO DO JOGO ---
p1_pos = 128
p2_pos = 128

ball_x = 256
ball_y = 128
ball_vel_x = 5
ball_vel_y = 0

p1_score_val = 0
p2_score_val = 0
endgame = 0
winner = 0
log_file = open("./movements_input.txt", "w")


score_font = pygame.font.SysFont("Arial", 18, 1, 0)
time_font = pygame.font.SysFont("Arial", 12, 0, 0)

p1_score = pygame.font.Font.render(score_font, "0", 0, "white")
p2_score = pygame.font.Font.render(score_font, "3", 0, "white")
txt_score = pygame.font.Font.render(score_font, "Score", 0, "white")

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    pressed_keys = pygame.key.get_pressed()

    if pressed_keys[pygame.K_w]:
        p1_mov = CIMA
    elif pressed_keys[pygame.K_s]:
        p1_mov = BAIXO
    else:
        p1_mov = PARADO

    if pressed_keys[pygame.K_UP]:
        p2_mov = CIMA
    elif pressed_keys[pygame.K_DOWN]:
        p2_mov = BAIXO
    else:
        p2_mov = PARADO

    if p1_mov == CIMA:
        p1_log = "010"
    elif p1_mov == BAIXO:
        p1_log = "000"
    else:
        p1_log = "001"

    if p2_mov == CIMA:
        p2_log = "010"
    elif p2_mov == BAIXO:
        p2_log = "000"
    else:
        p2_log = "001"
    log_file.write(f"{endgame}{winner}{p1_log}{p2_log}\n")
    
    # Desenvolvimento da física 
    if p1_mov == BAIXO:
        if (p1_pos + PLAYER_VEL + PLAYER_MID_LENGHT <= SCREEN_BOTTOM):
            p1_pos += PLAYER_VEL
        else:
            p1_pos = SCREEN_BOTTOM - PLAYER_MID_LENGHT
    elif p1_mov == CIMA:
        if (p1_pos - PLAYER_VEL - PLAYER_MID_LENGHT >= SCREEN_TOP):
            p1_pos -= PLAYER_VEL
        else:
            p1_pos = SCREEN_TOP + PLAYER_MID_LENGHT

    if p2_mov == BAIXO:
        if (p2_pos + PLAYER_VEL + PLAYER_MID_LENGHT <= SCREEN_BOTTOM):
            p2_pos += PLAYER_VEL
        else:
            p2_pos = SCREEN_BOTTOM - PLAYER_MID_LENGHT
    elif p2_mov == CIMA:
        if (p2_pos - PLAYER_VEL - PLAYER_MID_LENGHT >= SCREEN_TOP):
            p2_pos -= PLAYER_VEL
        else:
            p2_pos = SCREEN_TOP + PLAYER_MID_LENGHT

    ball_x += ball_vel_x
    ball_y += ball_vel_y


    if (ball_x <= 0 and not(ball_y <= p1_pos + PLAYER_MID_LENGHT and ball_y >= p1_pos - PLAYER_MID_LENGHT)):
        p2_score_val += 1
        ball_x = 256
        ball_y = 128
        ball_vel_x = 5
        ball_vel_y = 0
    elif (ball_x >= 512 and not(ball_y <= p2_pos + PLAYER_MID_LENGHT and ball_y >= p2_pos - PLAYER_MID_LENGHT)):
        p1_score_val += 1
        ball_x = 256
        ball_y = 128
        ball_vel_x = -5
        ball_vel_y = 0
    else:
        if ball_y <= SCREEN_TOP:
            ball_y = SCREEN_TOP + 2
            ball_vel_y *= -1
        elif ball_y >= SCREEN_BOTTOM:
            ball_y = SCREEN_BOTTOM - 2
            ball_vel_y *= -1
        else:
            if ((ball_x < 13) and 
                (ball_y <= p1_pos + PLAYER_MID_LENGHT and ball_y >= p1_pos - PLAYER_MID_LENGHT)):
                if p1_mov == BAIXO and ball_vel_y <= 0:
                    ball_vel_y = -ball_vel_y - VAR_VEL
                    ball_vel_x = -ball_vel_x - VAR_VEL
                elif p1_mov == CIMA and ball_vel_y >= 0:
                    ball_vel_y = -ball_vel_y + VAR_VEL
                    ball_vel_x = -ball_vel_x - VAR_VEL
                elif p1_mov == CIMA and ball_vel_y <= 0:
                    ball_vel_y =  ball_vel_y - VAR_VEL
                    ball_vel_x = -ball_vel_x + VAR_VEL
                elif p1_mov == BAIXO and ball_vel_y >= 0:
                    ball_vel_y =  ball_vel_y + VAR_VEL
                    ball_vel_x = -ball_vel_x + VAR_VEL
                else:
                    ball_vel_x *= -1
            elif ((ball_x > 499) and 
                (ball_y <= p2_pos + PLAYER_MID_LENGHT and ball_y >= p2_pos - PLAYER_MID_LENGHT)):
                if p2_mov == BAIXO and ball_vel_y <= 0:
                    ball_vel_y = -ball_vel_y - VAR_VEL
                    ball_vel_x = -ball_vel_x - VAR_VEL
                elif p2_mov == CIMA and ball_vel_y >= 0:
                    ball_vel_y = -ball_vel_y + VAR_VEL
                    ball_vel_x = -ball_vel_x - VAR_VEL
                elif p2_mov == CIMA and ball_vel_y <= 0:
                    ball_vel_y =  ball_vel_y - VAR_VEL
                    ball_vel_x = -ball_vel_x + VAR_VEL
                elif p2_mov == BAIXO and ball_vel_y >= 0:
                    ball_vel_y =  ball_vel_y + VAR_VEL
                    ball_vel_x = -ball_vel_x + VAR_VEL
                else:
                    ball_vel_x *= -1

    if p1_score_val == 5 or p2_score_val == 5:
        endgame = "1"
        if p1_score_val ==5 :
            winner = "0"
        else:
            winner = "1"
        running = False
        log_file.write(f"{endgame}{winner}{p1_log}{p2_log}\n")
    screen.fill("black")

    p1_score_txt = score_font.render(str(p1_score_val), True, "white")
    p2_score_txt = score_font.render(str(p2_score_val), True, "white")

    pygame.Surface.blit(screen, p1_score_txt, (210,3))
    pygame.Surface.blit(screen, p2_score_txt, (290,3))
    pygame.Surface.blit(screen, txt_score, (228,3))
    
    pygame.draw.line(screen, "white", (0, SCREEN_TOP), (512, SCREEN_TOP), 3)
    pygame.draw.line(screen, "white", (0, SCREEN_BOTTOM), (512, SCREEN_BOTTOM), 3)

    pygame.draw.line(screen, "white", (12, p1_pos + PLAYER_MID_LENGHT), (12, p1_pos - PLAYER_MID_LENGHT), 5)
    pygame.draw.line(screen, "white", (500, p2_pos + PLAYER_MID_LENGHT), (500, p2_pos - PLAYER_MID_LENGHT), 5)
    
    pygame.draw.circle(screen, "white", (ball_x, ball_y), 5) 

    pygame.display.flip()

    clock.tick(60)

log_file.close()
pygame.quit()