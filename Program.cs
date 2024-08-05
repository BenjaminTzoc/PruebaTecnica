using System;

namespace EvaluarNumeroApp
{
    // Clase para representar el resultado de la evaluación
    public class EvaluacionNumero
    {
        public bool EsPrimo { get; set; }
        public bool EsPar { get; set; }
    }

    class Program
    {
        static void Main(string[] args)
        {
            while (true)
            {
                Console.Clear(); // Limpiar la pantalla
                // Mostrar el menú de opciones
                Console.WriteLine("Seleccione una opción:");
                Console.WriteLine("1. Encontrar el mayor de tres números");
                Console.WriteLine("2. Evaluar si un número es primo y/o par");
                Console.WriteLine("3. Salir");

                string opcion = Console.ReadLine();

                Console.Clear(); // Limpiar la pantalla antes de mostrar resultados

                switch (opcion)
                {
                    case "1":
                        EncontrarMayorMenu();
                        break;
                    case "2":
                        EvaluarNumeroMenu();
                        break;
                    case "3":
                        return; // Salir del programa
                    default:
                        Console.WriteLine("Opción no válida. Por favor, intente de nuevo.");
                        break;
                }

                Console.WriteLine("Presione cualquier tecla para continuar...");
                Console.ReadKey(); // Esperar a que el usuario presione una tecla
            }
        }

        // Menú para encontrar el mayor de tres números
        static void EncontrarMayorMenu()
        {
            Console.Clear(); // Limpiar la pantalla
            // Leer y validar el primer número
            Console.WriteLine("Ingrese el primer número:");
            if (!int.TryParse(Console.ReadLine(), out int num1))
            {
                Console.WriteLine("Por favor, ingrese un número válido.");
                return;
            }

            // Leer y validar el segundo número
            Console.WriteLine("Ingrese el segundo número:");
            if (!int.TryParse(Console.ReadLine(), out int num2))
            {
                Console.WriteLine("Por favor, ingrese un número válido.");
                return;
            }

            // Leer y validar el tercer número
            Console.WriteLine("Ingrese el tercer número:");
            if (!int.TryParse(Console.ReadLine(), out int num3))
            {
                Console.WriteLine("Por favor, ingrese un número válido.");
                return;
            }

            // Encontrar el mayor de los tres números
            int mayor = EncontrarMayor(num1, num2, num3);
            Console.WriteLine($"El mayor de los tres números es: {mayor}");
        }

        // Menú para evaluar si un número es primo y/o par
        static void EvaluarNumeroMenu()
        {
            Console.Clear(); // Limpiar la pantalla
            Console.WriteLine("Ingrese un número:");
            if (int.TryParse(Console.ReadLine(), out int numero))
            {
                EvaluacionNumero evaluacion = EvaluarNumero(numero);
                Console.WriteLine($"El número {numero} es par: {evaluacion.EsPar}, es primo: {evaluacion.EsPrimo}");
            }
            else
            {
                Console.WriteLine("Por favor, ingrese un número válido.");
            }
        }

        // Función para encontrar el mayor de tres números
        static int EncontrarMayor(int a, int b, int c)
        {
            if (a >= b && a >= c)
            {
                return a;
            }
            else if (b >= a && b >= c)
            {
                return b;
            }
            else
            {
                return c;
            }
        }

        // Función para evaluar si un número es primo y/o par
        static EvaluacionNumero EvaluarNumero(int n)
        {
            return new EvaluacionNumero
            {
                EsPrimo = EsPrimo(n),
                EsPar = EsPar(n)
            };
        }

        // Función para verificar si un número es primo
        static bool EsPrimo(int n)
        {
            if (n <= 1) return false;
            if (n == 2) return true;
            if (n % 2 == 0) return false;

            for (int i = 3; i <= Math.Sqrt(n); i += 2)
            {
                if (n % i == 0) return false;
            }

            return true;
        }

        // Función para verificar si un número es par
        static bool EsPar(int n)
        {
            return n % 2 == 0;
        }
    }
}
