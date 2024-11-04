; Nom du fichier PEP/8 ? dÃ©terminer !
;
;    AUTEUR-S    : Justin Fiset, Vincent Moreau-Benoit, Mathis Odjo'o Ada, Nikola Sunjka
;    DATE        : 10/11/2024 
;    ?QUIPE      : Gr-01-Equipe 08
;    DESCRIPTION :
;
;      Ce programme a pour objectif de lire une s?quence binaire de 32 bits, entr?e au clavier
;      par l'utilsateur, repr?santant un nombre flottant au format IEEE 754 pour ensuite 
;      le convertir en sa repr?sentation d?cimale.       (Trop long ?)



TAILLE:  .EQUATE 32 ; la taille du tableau en byte
N_EXPO:  .EQUATE 8 ; Le nombre de bit qui servent ? repr?senter l'exposant

BIAIS_EX:.EQUATE 127 ; le biais de l'exposant selon la norme IEEE754
NEGATIF: .EQUATE 1 ; la valeur du bit de signe si le nombre est n?gatif

         
; TODO IL FAUT FIX LA MANI?RE DONT LES IF SONT FAIT ET LES FAIRES COMME L'EXAMPLE DU PROF
main:    STRO msg_inpt, d ; On d?crit ? l'utilisateur ce qu'il tape sur le clavier
         
         LDX 0, i ; On s'assure que l'indice est bien initialement ? 0
         for_1:  CPX TAILLE, i ; if(x == TAILLE)
                 BREQ end_1   ;     a_end_1() 
         
                
                 CHARI v, d ; On demande un char

                 ; Si l'entr?e de l'utilisateur est un 0 ou un 1 (ascii)  
                 LDBYTEA v, d   

                 CPA '0', i
                 BREQ add_0 ; on ajoute au tableau la valeur 0 
                 CPA '1', i
                 BREQ add_1 ; on ajoute au tableau la valeur 1
                 BR for_1 ; Sinon, on a pas ce que l'on veux, on redemande 
                 
                 
                 ; Si les conditions sont satisfaitent, on ajoute la valeur au tableau
                 add_0:      LDBYTEA 0, i   ; tab[x] = 0 -> on met la valeur entrÃ©e dans le tableau 
                             STBYTEA tab, x 
                             BR run_1 

                 add_1:      LDBYTEA 1, i   ; tab[x] = 0 -> on met la valeur entr?e dans le tableau
                             STBYTEA tab, x 
                             BR run_1

                 run_1:      ADDX 1, i ; on incr?mente le compteur car valeur ok
                             BR for_1 ; on relance la boucle  
         
         end_1:  LDX N_EXPO, i ; On va chercher le bit le plus loin de l'exposant
                

         ; CALCUL DE L'EXPOSANT
         for_2:  CPX 0, i
                 BREQ end_2

                 LDBYTEA tab, x ; Si la valeur ? tab[x] == 1
                 CPA 1, i   ;    -> On ajoute 2^x ? la valeur de l'exposant
                 BREQ add_expo 
                 BR run_2 ; Sinon on relance directement la boucle 
                             
                 add_expo:   LDA expo, d ; expo += exp_bit
                             ADDA exp_bit, d
                             STA expo, d

                 run_2:      LDA exp_bit, d  ; on double la valeur de expo_bit
                             ADDA exp_bit, d ; CODE: exp_bit += exp_bit
                             STA exp_bit, d

                             SUBX 1, i ; puisque l'on part de la fin de l'exposant on d?cr?mente
                             BR for_2 ; on relance la boucle

         end_2:  LDA expo, d ; On soustrait le biais à la valeur de l'exposant calculé
                 SUBA BIAIS_EX, i ; CODE JAVA: exp -= biais (selon la convention)
                 STA expo, d
                 STRO test, d ;TODO ENLEVER DEBU
                 DECO expo, d ; Test pour afficher l'exposant // TODO ENLEVER
                 CHARO '\n', i; // TODO ENLEVER
         
         ; Preparation au remplissage des tableaux de chacune des parties de la mantisse
         LDA N_EXPO, i ; On va stocker l'indice dans le tableau original
         ADDA 1, i
         STA i_tab, d 

         LDA expo, d   ; if (expo < 0)
         CPA 0, i      ;     fill_fra()
         BRLT fill_fra ; else 
         BR fill_ent   ;     fill_ent()   

         fill_fra:LDX expo, d 
                 NEGX
                 LDBYTEA 1, i
                 STBYTEA fraction, x ; On vient stocker le 1 implicite de la mantisse 
                 ADDX 1, i
                 STX i_manti, d ; i_tab = exp (on set le compteur/indice dans le tableau)

                 LDX 0, i ; On initialise le compteur à 0
                 STX cpt, d
                 for_3:      CPX 23, i ; TODO METTE EN CONSTANTE OU LOADER I_TAB POUR VOIR SI == 32, REVIENT AU MÊME
                             BREQ end_3 

                             LDX i_tab, d
                             LDBYTEA tab, x
                             ADDX 1, i
                             STX i_tab, d

                             LDX i_manti, d
                             STBYTEA fraction, x
                             ADDX 1, i
                             STX i_manti, d

                             LDX cpt, d 
                             ADDX 1, i
                             STX cpt, d
                             BR for_3
                        
                 end_3: BR aff_enti ; TODO MODIFER À UNE AUTRE INSTRUCTION 

         fill_ent: NOP1
                 ldx 122, i
                 ldbytea 2, i
                 stbytea entier, x

                 LDX 129, i ; TODO mettre en constante
                 SUBX expo, d ; i_manti = TAIL_ENT - 1 - expo
                 LDBYTEA 1, i ; Charger le 1 implicite de la mantisse dans l'accumulateur
                 STBYTEA entier, x ; On met le 1 implicite de la mantisse dans la partie entière
                 STX i_manti, d ; On stock l'indice dans la partie entière de la mantisse
                 
                 LDX 0, i ; Initialisation du compteur à 0
                 STX cpt, d 
                 ; Remplissage de la partie entière (uniquement)
                 for_4:      CPX expo, d
                             charo '!', i
                             BREQ end_4
                             LDX i_tab, d
                             LDBYTEA tab, x ; On charge la valeur que l'on veut mettre dans la partie entière
                             ADDX 1, i    ; Incémentation et stockage de l'indice dans le tableau des valeurs entrees
                             STX i_tab, d
         
                             LDX i_manti, d ; Stockage de la valeur au bon indice dans la partie entière
                             STBYTEA entier, x
                             ADDX 1, i ; Incrémentation de l'indice dans la partie entière
                             STX i_manti, d
         
                             LDX cpt, d ; incrémentation du compteur
                             ADDX 1, i
                             STX cpt, d
                             BR for_4 ; rebranchement de la boucle
                 end_4:      charo '!', i

                 LDA 0, i ; reset du compteur de la mantisse à 0, on change de tableau
                 STA i_manti, d
                 charo '!', i 
                 ; On remplit tout les autres bits dans la partie fractionère
                 for_5:      CPX 23, i
                             BRGE end_5

                             LDX i_tab, d
                             LDBYTEA tab, x
                             ADDX 1, i
                             STX i_tab, d

                             LDX i_manti, d
                             STBYTEA fraction, x
                             ADDX 1, i
                             STX i_manti, d

                             LDX cpt, d ; incrémentation du compteur
                             ADDX 1, i
                             STX cpt, d
                             BR for_5 ; rebranchement de la boucle
                 end_5:      NOP1
        
         
         ; TODO AU LIEU DE RETIRER, MODIFIER POUR CALCULER À LA PLACE, CAR LA BOUCLE FONCTIONNE DEJA
         ; TODO RETIRER TOUTE CETTE SECTION DEBUG SEULEMENT
         aff_enti:LDX 0, i
                 for_7:      CPX 129, i ; TODO METTRE EN CONSTANTE
                             BREQ end_7

                             LDBYTEA entier, x
                             ADDA '0', i
                             STBYTEA char_o, d
                             CHARO char_o, d

                             ADDX 1, i; x++
                             BR for_7 ; on recommence la boucle

                 end_7:      CHARO '\n', i
        ; DEBUG SEULEMENT RETIRER ABSOLUMENT AVANT LA REMISE AU PROF
         aff_frac:LDX 0, i
                 for_6:      CPX 151, i ; TODO METTRE EN CONSTANTE
                             BREQ end_6

                             LDBYTEA fraction, x
                             ADDA '0', i
                             STBYTEA char_o, d
                             CHARO char_o, d

                             ADDX 1, i; x++
                             BR for_6 ; on recommence la boucle
                 end_6:      NOP1
                                
         STOP


                 
v:       .BYTE 0 ; la valeur de l'entr?e de l'utilisateur
exp_bit: .WORD 1 ; la valeur de l'exposant li? ? un bit; Ex: 2^n 
expo:    .WORD 0 ; la valeur de l'exposant
cpt:     .WORD 0 ; compteur d'itération dans les boucles
char_o:  .BYTE 0 ; un char que l'on veut afficher

test:    .ASCII "\nTest : " ; // TODO ENLEVER 

i_tab:   .WORD 0 ; l'index dans le tableau
i_manti: .WORD 0 ; l'indice dans la partie de la mantisse
tab:     .BLOCK 32



entier:  .BLOCK 129 ; Le tableau qui contient la partie entière de la mantisse
fraction:.BLOCK 151 ; Le tableau qui contient la partie fracitonère de la mantisse


msg_inpt:.ASCII "Entrez 32 valeurs (0 ou 1) qui reprÃ©sentent un nombre Ã  virgule flottante: \x00"


.END ; on ferme le programme
