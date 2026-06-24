import pygame

# pygame setup
pygame.init()
screen = pygame.display.set_mode((512, 256))
clock = pygame.time.Clock()
running = True
p1_pos = 128
p2_pos = 128

ball_x = 256
ball_y = 128

score_font = pygame.font.SysFont("Arial", 18, 1, 0)
time_font = pygame.font.SysFont("Arial", 12, 0, 0)

p1_score = pygame.font.Font.render(score_font, "0", 0, "white")
p2_score = pygame.font.Font.render(score_font, "3", 0, "white")
txt_score = pygame.font.Font.render(score_font, "Score", 0, "white")

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # fill the screen with a color to wipe away anything from last frame
    screen.fill("black")

    pygame.Surface.blit(screen, p1_score, (210,3))
    pygame.Surface.blit(screen, p2_score, (290,3))
    pygame.Surface.blit(screen, txt_score, (228,3))
    
    pygame.draw.line(screen, "white", (0, 25), (512, 25), 3)
    pygame.draw.line(screen, "white", (0, 231), (512, 231), 3)

    pygame.draw.line(screen, "white", (12, p1_pos + 24), (12, p1_pos -24), 5)
    pygame.draw.line(screen, "white", (500, p2_pos + 24), (500, p2_pos -24), 5)
    
    pygame.draw.circle(screen, "white", (ball_x, ball_y), 5) 


    keys = pygame.key.get_pressed()
    # flip() the display to put your work on screen
    pygame.display.flip()


pygame.quit()

