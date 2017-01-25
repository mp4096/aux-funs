%% Integrate Existing C Function into Simulink Model with the Legacy Code Tool
clear mex;

% Create a Legacy Code Tool data structure 
def = legacy_code('initialize');
def.Options.language = 'C';

% Specify Source Files:
def.SourceFiles = {'CholeskyDowndateReal_SFunWrapper.c'};

% Specify Header Files:
def.HeaderFiles = {'math.h', 'stdlib.h', 'string.h', 'CholeskyDowndateReal_SFunWrapper.h'};

% Specify information about S-function
def.SFunctionName = 'sfun_chol_downdate_real';
def.OutputFcnSpec = 'int32 y2 = sFunWrapper(double y1[size(u1,1)][size(u1,2)], uint32 p1[1], double u1[][], double u2[])';

%% Compilation
% Generate an S-function source file
legacy_code('sfcn_cmex_generate', def);

% Compile the s-function with optional compilerflags
legacy_code('compile', def, '-g');

%% Generate a TLC file and simulation block
legacy_code('slblock_generate', def);
legacy_code('sfcn_tlc_generate', def);
% Mandatory, because not all the source and header files are in the same folder
legacy_code('rtwmakecfg_generate', def);