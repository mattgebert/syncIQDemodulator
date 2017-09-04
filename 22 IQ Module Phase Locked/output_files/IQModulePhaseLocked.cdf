/* Quartus II 64-Bit Version 13.1.0 Build 162 10/23/2013 SJ Web Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(SOCVHPS) MfrSpec(OpMask(0));
	P ActionCode(Cfg)
		Device PartName(5CSEMA5F31) Path("/home/matt-g/Documents/20170815Quartus/22 IQ Module Phase Locked/output_files/") File("IQModulePhaseLocked.sof") MfrSpec(OpMask(1));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
