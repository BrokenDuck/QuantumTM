namespace GraphColoring
{
    open Microsoft.Quantum.Convert as Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement as Measurement;
    open Microsoft.Quantum.Arrays as Arrays;


    /// # Summary
    /// Given a qubit register, will return the integer
    /// corresponding the the binary in little endian format.
    operation measureColor (register : Qubit[]) : Int {
        return Convert.ResultArrayAsInt(Measurement.MultiM(register));
    }

    /// # Summary
    /// Given a register of multiple colors in little endian format
    /// and the number of colors in the array,
    /// will return an array with the corresponding integers.
    operation measureColoring (numberElements : Int, register : Qubit[]) : Int[] {
        let elementSize = Length(register)/numberElements;
        let splicedArray = Arrays.Chunks(elementSize, register);
        return Arrays.ForEach(measureColor, splicedArray);
    }

    /// # Summary
    /// Flips a target qubit if 2 colors are equal
    /// # Input
    /// ## c0
    /// Register of qubits representing the first color
    /// ## c1
    /// Register of qubits representing the second color
    /// ## target
    /// target qubit to flip if the colors are equal
    operation ColorEqualityOracle_Nbit (c0 : Qubit[], c1 : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        for ((q0, q1) in Arrays.Zip(c0, c1)) {
            CNOT(q0, q1);
        }
        (ControlledOnInt(0, X))(c1, target);
        for ((q0, q1) in Arrays.Zip(c0, c1)) {
            CNOT(q0, q1);
        }
    }

    /// # Summary
    /// Converts a bit-flipping oracle in a phase-flipping oracle.
    ///
    /// # Description
    /// Applying a bit-flip to the |-> state converts it to -|->
    /// only flipping the phase.
    ///
    /// # Type Parameters
    /// ## Qubit[]
    /// The register to analyse
    /// ## Qubit
    /// The target qubit to flip
    operation oracleConverter (markingOracle : ((Qubit[], Qubit) => Unit is Adj), register : Qubit[]) : Unit is Adj {
        using (target = Qubit()) {
            X(target);
            H(target);
            markingOracle(register, target);
            H(target);
            X(target);
        }
    }

    /// # Summary
    /// Applies grovers algorithm when provided an bit-flip oracle, a register and the the number of iterations
    ///
    /// # Description
    /// View https://en.wikipedia.org/wiki/Grover%27s_algorithm
    operation groverAlgorithm (markingOracle : ((Qubit[], Qubit) => Unit is Adj), register : Qubit[], iterations : Int) : Unit is Adj {
        let phaseOracle = oracleConverter(markingOracle, _);
        ApplyToEachA(H, register);
        for (i in 1..iterations) {
            phaseOracle(register);
            ApplyToEachA(H, register);
            ApplyToEachA(X, register);
            (Controlled Z)(Arrays.Most(register), Arrays.Tail(register));
            ApplyToEachA(X, register);
            ApplyToEachA(H, register);

        }
    }

    /// # Summary
    /// The oracle to test the coloring of the graph
    ///
    /// # Description
    /// Will look at every edge and look if the colors of the two vertices are different,
    /// if all thee colors are different, will flip the target qubit
    operation vertexColoringOracle (V : Int, edges : (Int, Int)[], colorsRegister : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        let numberEdges = Length(edges);
        using (correctness = Qubit[numberEdges]) {
            for (i in 0..numberEdges - 1) {
                let (v0, v1) = edges[i];
                ColorEqualityOracle_Nbit(colorsRegister[v0*2 .. v0*2+1], colorsRegister[v1*2 .. v1*2+1], correctness[i]);
            }
            (ControlledOnInt(0, X))(correctness, target);

            for (i in 0..numberEdges - 1) {
                let (v0, v1) = edges[i];
                Adjoint ColorEqualityOracle_Nbit(colorsRegister[v0*2 .. v0*2+1], colorsRegister[v1*2 .. v1*2+1], correctness[i]);  
            }
        }
    }

    /// # Summary
    /// When given an oracle and the number of vertices, will return a valid coloring if possible
    ///
    /// # Description
    /// Will try up to 10 iterations to find a valid coloring using @"groverAlgorithm" by :
    /// - Applying grovers algorithm with i iterations
    /// - Measuring the register
    /// - Verifying the solution with another qubit and the oracle
    /// - If the solution is True outputing the oracle using @"measureColoring", else repeating
    /// 
    /// # Input
    /// ## oracle
    /// A black-box oracle which flips a qubit if the result is correct
    /// ## V
    /// The number of vertices of the graph
    /// 
    /// # Output
    /// An array of integers representing the colors
    ///
    /// # Type Parameters
    /// ## Qubit[]
    /// The register of qubits the oracle should analyse
    /// ## Qubit
    /// The target qubbit the register flips if the answer is correct
    /// 
    /// # Remarks
    /// The color register has to be of size 2*V since the maximum number of colors is 4 which can be stored in 2 bits
    /// (see : https://en.wikipedia.org/wiki/Four_color_theorem)
    operation graphColoringMain (V : Int, edges : (Int, Int)[]) : Int[] {
        mutable coloring = new Int[V];
        let oracle = vertexColoringOracle(V, edges, _, _);

        using ((register, output) = (Qubit[2 * V], Qubit())) {
            mutable correct = false;
            mutable iterations = 1;
            repeat {
                Message($"Trying iteration {iterations}");
                groverAlgorithm(oracle, register, iterations);
                let temp = Measurement.MultiM(register);
                oracle(register, output);
                if (Measurement.MResetZ(output) == One) {
                    set correct = true;
                    set coloring = measureColoring(V, register);
                }
                ResetAll(register);
            }
            until (correct or iterations > 10)
            fixup {
                set iterations += 1;
            }
            if (not correct) {
                fail "No valid coloring was found";
            }
        }
        return coloring;
    }
}