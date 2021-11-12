# RISC-V Pipeline

![Processador RISC-V Pipeline](https://i.imgur.com/JPNg88P.jpg)

Implementação de um processador RISC V Pipeline na linguagem VHDL como projeto final da disciplina Arquiteturas VLSI. 
Autor: Paulo Victor Gonçalves Farias / Matrícula: 20/0052039

# Descrição do Projeto
A arquitetura do processador foi dividida em 5 estágios principais. 
* Fetch Stage
* Decode Stage
* Execute Stage
* Memory Stage
* Writeback Stage

O arquivo principal <em>riscv_pipeline</em> contém a instaciação de cada um dos componentes. O arquivo <em>riscv_package</em> contém as descrições de todos os componentes, constantes e alias utilizados.

# Fetch Stage
Calcula o próximo PC e pega a próxima instrução que será executada utilizando a memória de instruções.
- **Fetch Stage:** <em>fetch_stage.vhd, fetch_stage_tb.vhd</em>
- **Memória de Instruções:** <em>memInstr.vhd, memInstr_tb.vhd</em>

# Decode Stage
Decodifica a instrução de acordo com a sua estrutura, contém também o controle para definir quais sinais deverão ser ativos ou não. Faz uso do banco de registradores e do gerador de imediato.
- **Decode Stage:** <em>decode_stage.vhd, decode_stage_tb.vhd</em>
- **Controle:** <em>control.vhd</em>
- **Banco de Registradores:** <em>xregs.vhd, xregs_tb.vhd</em>
- **Gerador de Imediato:** <em>immediateGen.vhd, immediateGen_tb.vhd</em>

# Execute Stage
Realiza a execução da instrução tratando da ALU e da parte de <em>branching</em>.
- **Execute Stage:** <em>execute_stage.vhd, execute_stage_tb.vhd</em>
- **ALU:** <em>alu.vhd, alu_tb.vhd, alu_ctr.vhd</em>

# Memory Stage
Realiza as tarefas necessárias com a memória de dados. 
- **Memory Stage:** <em>memory_stage.vhd, memory_stage_tb.vhd</em>
- **Memória de Dados:** <em>memData.vhd, memData_tb.vhd</em>

# Writeback Stage
Escreve os resultados nos registradores.
- **Writeback Stage:** <em>writeback_stage.vhd, writeback_stage_tb.vhd</em>
