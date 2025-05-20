import java.util.Scanner;
import java.util.Random;

public class App {

    public static final int MAX_CARTAS_MAO = 10;

    public static int compraCartas() {
        Random random = new Random();
        return random.nextInt(13) + 1;
    }

    public static int calculaPontuacaoMao(int[] mao, int numCartas) {
        int pontosTotal = 0;
        int numAses = 0;

        for (int i = 0; i < numCartas; i++) {
            int carta = mao[i];
            if (carta >= 2 && carta <= 10) { 
                pontosTotal += carta;
            } else if (carta >= 11 && carta <= 13) { 
                pontosTotal += 10;
            } else if (carta == 1) { 
                pontosTotal += 11;
                numAses++;
            }
        }

        while (pontosTotal > 21 && numAses > 0) {
            pontosTotal -= 10; 
            numAses--;
        }

        return pontosTotal;
    }

    public static void exibeMao(int[] mao, int numCartas, boolean ocultaSegunda) {
        System.out.print("[ ");
        for (int i = 0; i < numCartas; i++) {
            if (ocultaSegunda && i == 1) { 
                System.out.print("? ");
            } else {
                int carta = mao[i];
                if (carta == 1) {
                    System.out.print("A ");
                } else if (carta == 11) {
                    System.out.print("J ");
                } else if (carta == 12) {
                    System.out.print("Q ");
                } else if (carta == 13) {
                    System.out.print("K ");
                } else {
                    System.out.print(carta + " ");
                }
            }
        }
        System.out.println("]");
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        Random random = new Random(); 

        System.out.println("Bem-vindo ao Blackjack!"); 

        int jogarNovamente = 1; 


        while (jogarNovamente == 1) {
            System.out.println("\nNova Rodada!");


            int[] maoJogador = new int[MAX_CARTAS_MAO];
            int numCartasJogador = 0;
            int pontosJogador = 0;

            int[] maoDealer = new int[MAX_CARTAS_MAO];
            int numCartasDealer = 0;
            int pontosDealer = 0;

            maoJogador[numCartasJogador++] = compraCartas();
            maoJogador[numCartasJogador++] = compraCartas();
            pontosJogador = calculaPontuacaoMao(maoJogador, numCartasJogador);

            maoDealer[numCartasDealer++] = compraCartas();
            maoDealer[numCartasDealer++] = compraCartas();
            pontosDealer = calculaPontuacaoMao(maoDealer, numCartasDealer); 

            System.out.print("Sua mão: ");
            exibeMao(maoJogador, numCartasJogador, false);
            System.out.println("(Soma: " + pontosJogador + ")");

            System.out.print("Mão do Dealer: ");
            int[] maoDealerVisivel = {maoDealer[0], 0};
            System.out.print("[ ");
            System.out.print(maoDealer[0] == 1 ? "A " : (maoDealer[0] == 11 ? "J " : (maoDealer[0] == 12 ? "Q " : (maoDealer[0] == 13 ? "K " : maoDealer[0] + " "))));
            System.out.println("? ]");

            boolean jogadorParou = false;
            boolean jogadorEstourou = false;

            while (!jogadorParou && !jogadorEstourou) {
                System.out.println("\nO que você deseja fazer?"); 
                System.out.println("1 - Pedir mais (Hit)"); 
                System.out.println("2 - Parar (Stand)"); 

                int escolhaJogador = scanner.nextInt();

                if (escolhaJogador == 1) { 
                    if (numCartasJogador < MAX_CARTAS_MAO) {
                        int novaCarta = compraCartas();
                        maoJogador[numCartasJogador++] = novaCarta;
                        pontosJogador = calculaPontuacaoMao(maoJogador, numCartasJogador);

                        System.out.println("Você recebeu: " + (novaCarta == 1 ? "A" : (novaCarta == 11 ? "J" : (novaCarta == 12 ? "Q" : (novaCarta == 13 ? "K" : String.valueOf(novaCarta))))));
                        System.out.print("Sua mão: ");
                        exibeMao(maoJogador, numCartasJogador, false);
                        System.out.println("(Soma: " + pontosJogador + ")");

                        if (pontosJogador > 21) {
                            System.out.println("Estourou!");
                            jogadorEstourou = true;
                        }
                    } else {
                        System.out.println("Sua mão está cheia, não pode receber mais cartas.");
                        jogadorParou = true; 
                    }
                } else if (escolhaJogador == 2) {
                    jogadorParou = true;
                    System.out.println("Você parou.");
                } else {
                    System.out.println("Opção inválida. Tente novamente.");
                }
            }

            if (!jogadorEstourou) {
                System.out.println("\nVez do Dealer!"); 
                System.out.println("Dealer revela a carta oculta:");

                System.out.print("Mão do Dealer: ");
                exibeMao(maoDealer, numCartasDealer, false);
                System.out.println("(Soma: " + pontosDealer + ")");

                while (pontosDealer < 17) {
                    System.out.println("Dealer precisa pedir (< 17)...");
                    if (numCartasDealer < MAX_CARTAS_MAO) {
                        int novaCartaDealer = compraCartas();
                        maoDealer[numCartasDealer++] = novaCartaDealer;
                        pontosDealer = calculaPontuacaoMao(maoDealer, numCartasDealer);

                        System.out.println("Dealer recebe: " + (novaCartaDealer == 1 ? "A" : (novaCartaDealer == 11 ? "J" : (novaCartaDealer == 12 ? "Q" : (novaCartaDealer == 13 ? "K" : String.valueOf(novaCartaDealer))))));
                        System.out.print("Mão do Dealer: ");
                        exibeMao(maoDealer, numCartasDealer, false);
                        System.out.println("(Soma: " + pontosDealer + ")");

                        if (pontosDealer > 21) {
                            System.out.println("Estourou!");
                            break; 
                        }
                    } else {
                        System.out.println("Mão do Dealer cheia.");
                        break; 
                    }
                }
                if (pontosDealer >= 17 && pontosDealer <= 21) {
                    System.out.println("Dealer parou (>= 17).");
                }
            }

            System.out.println("\n--- Resultados Finais ---");
            System.out.println("Sua Pontuação: " + pontosJogador);
            System.out.println("Pontuação do Dealer: " + pontosDealer);

            if (jogadorEstourou) {
                System.out.println("*** Dealer Venceu! (Você estourou) ***");
            } else if (pontosDealer > 21) {
                System.out.println("*** Você Venceu! (Dealer estourou) ***");
            } else if (pontosJogador > pontosDealer) {
                System.out.println("*** Você Venceu! ***");
            } else if (pontosDealer > pontosJogador) {
                System.out.println("*** Dealer Venceu! ***");
            } else {
                System.out.println("*** Empate! ***"); 
            }

            System.out.println("\nDeseja jogar novamente? (1 - Sim, 2 - Não):");
            jogarNovamente = scanner.nextInt();

            if (jogarNovamente == 2) {
                System.out.println("Obrigado por jogar!"); 
            } else if (jogarNovamente != 1) {
                System.out.println("Opção inválida. Assumindo 'Não'.");
                jogarNovamente = 2;
            }
        }
        scanner.close(); 
    }
}