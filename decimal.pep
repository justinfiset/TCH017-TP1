TAILLE:  .EQUATE 32 ; la taille du tableau en byte
N_EXPO:  .EQUATE 8 ; Le nombre de bit qui servent à représenter l'exposant

BIAIS_EX:.EQUATE 127 ; le biais de l'exposant selon la norme IEEE754
NEGATIF: .EQUATE 1 ; la valeur du bit de signe si le nombre est négatif

         
; TODO IL FAUT FIX LA MANIÈRE DONT LES IF SONT FAIT ET LES FAIRES COMME L'EXAMPLE DU PROF
main:    STRO msg_inpt, d ; On décrit à l'utilisateur ce qu'il tape sur le clavier
         
         LDX 0, i ; On s'assure que l'indice est bien initialement à 0
         for_1:  CPX TAILLE, i ; if(x == TAILLE)
                 BREQ end_1   ;     a_end_1() 
         
                 CHARI v, d ; On demande un char

                 ; Si l'entrée de l'utilisateur est un 0 ou un 1 (ascii)  
                 LDBYTEA v, d   
                 CPA '0', i
                 BREQ add_0 ; on ajoute au tableau la valeur 0 
                 CPA '1', i
                 BREQ add_1 ; on ajoute au tableau la valeur 1
                 BR for_1 ; Sinon, on a pas ce que l'on veux, on redemande 
                 
                 
                 ; Si les conditions sont satisfaitent, on ajoute la valeur au tableau
                 add_0:      LDBYTEA 0, i   ; tab[x] = 0 -> on met la valeur entrée dans le tableau 
                             STBYTEA tab, x 
                             BR run_1 
                 add_1:      LDBYTEA 1, i   ; tab[x] = 0 -> on met la valeur entrée dans le tableau
                             STBYTEA tab, x 
                             BR run_1

                 run_1:      ADDX 1, i ; on incrémente le compteur car valeur ok
                             BR for_1 ; on relance la boucle  
      
         
         end_1:  LDX N_EXPO, i ; On va chercher le bit le plus loin de l'exposant

         ; CALCUL DE L'EXPOSANT
         for_2:  CPX 0, i
                 BREQ end_2

                 LDBYTEA tab, x ; Si la valeur à tab[x] == 1
                 CPA 1, i   ;    -> On ajoute 2^x à la valeur de l'exposant
                 BREQ add_expo 
                 BR run_2 ; Sinon on relance directement la boucle 

                 add_expo:   LDA expo, d ; expo += exp_bit
                             ADDA exp_bit, d
                             STA expo, d

                 run_2:      LDA exp_bit, d  ; on double la valeur de expo_bit
                             ADDA exp_bit, d ; CODE: exp_bit += exp_bit
                             STA exp_bit, d

                             SUBX 1, i ; puisque l'on part de la fin de l'exposant on décrémente
                             BR for_2 ; on relance la boucle

         end_2:  LDA expo, d
                 SUBA BIAIS_EX, i
                 STA expo, d
                 DECO expo, d ; TODO ENLEVER

                 
                 
v:       .BYTE 0 ; la valeur de l'entrée de l'utilisateur
exp_bit: .WORD 1 ; la valeur de l'exposant lié à un bit; Ex: 2^n 
expo:    .WORD 0 ; la valeur de l'exposant

i_tab:   .WORD 0 ; l'index dans le tableau
tab:     .BLOCK 32
signe:   .BYTE 0 ; 1 ou 0

msg_inpt:.ASCII "Entrez 32 valeurs (0 ou 1) qui représentent un nombre à virgule flottante: \x00"


.END ; on femre le programme