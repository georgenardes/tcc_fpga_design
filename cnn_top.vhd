-- CNN top file
-- integra todas as camadas da rede


library ieee;
use ieee.std_logic_1164.all;
library work;
use work.types_pkg.all;


entity cnn_top is
  port 
  (
    i_CLK       : in STD_LOGIC;
    i_CLR       : in STD_LOGIC;
    i_GO        : in STD_LOGIC;
    i_LOAD      : in std_logic;
    o_READY     : out std_logic
  );
end cnn_top;

architecture arch of cnn_top is 
   
  constant DATA_WIDTH : integer := 8;
  constant ADDR_WIDTH : integer := 10;
  constant CONV1_H : integer := 34; -- iFMAP Height 
  constant CONV1_W : integer := 26; -- iFMAP Width 
  constant CONV1_C : integer := 3; -- iFMAP Chanels (filter Chanels also)
  constant CONV1_R : integer := 3; -- filter Height 
  constant CONV1_S : integer := 3; -- filter Width     
  constant CONV1_M : integer := 6; -- Number of filters (oFMAP Chanels also)      
  constant CONV1_NUM_PES_FILTER_CHA : std_logic_vector := "1000"; -- quantidade de peso por filtro por canal(R*S) (de 0 a 8)
  constant CONV1_LAST_PES : std_logic_vector := "10100010"; -- quantidade de pesos (162)
  constant CONV1_LAST_BIAS : std_logic_vector := "1100"; -- quantidade de bias e scale (12)    
  constant CONV1_LAST_ROW : std_logic_vector := "100010"; -- 34 (0 a 33 = 34 pixels) (2 pixels de pad)
  constant CONV1_LAST_COL : std_logic_vector := "11010";   -- 26 (0 a 25 = 26 pixels) (2 pixels de pad)
  constant CONV1_NC_SEL_WIDTH : integer := 2; -- largura de bits para selecionar saidas dos NCs de cada filtro  
  constant CONV1_NC_ADDRESS_WIDTH : integer := 5; -- num bits para enderecamento de NCs
  constant CONV1_NC_OHE_WIDTH : integer := 18; -- numero de bits para one-hot-encoder de NCs
  constant CONV1_BIAS_OHE_WIDTH : integer := 12; -- numero de bits para one-hot-encoder de bias e scales
  constant CONV1_WEIGHTS_ADDRESS_WIDTH : integer := 10; -- numero de bits para enderecar pesos
  constant CONV1_BIAS_ADDRESS_WIDTH : integer := 6; -- numero de bits para enderecar registradores de bias e scale
  constant CONV1_SCALE_SHIFT  : t_ARRAY_OF_INTEGER(0 to CONV1_M-1) := (8, 8, 7, 8, 8, 9); --num bits to shift
  constant CONV1_WEIGHTS_FILE_NAME     : string := "conv1.mif";
  constant CONV1_BIAS_FILE_NAME        : string := "conv1_bias.mif";
  ------------------------------------------------------------------
  constant CONV2_H : integer := 18; -- iFMAP Height 
  constant CONV2_W : integer := 14; -- iFMAP Width 
  constant CONV2_C : integer := 6; -- iFMAP Chanels (filter Chanels also)
  constant CONV2_R : integer := 3; -- filter Height 
  constant CONV2_S : integer := 3; -- filter Width     
  constant CONV2_M : integer := 16; -- Number of filters (oFMAP Chanels also)        
  constant CONV2_NUM_PES_FILTER_CHA : std_logic_vector := "1000"; -- quantidade de peso por filtro por canal(R*S) (de 0 a 8)
  constant CONV2_LAST_PES : std_logic_vector := "1101100000"; -- quantidade de pesos (864)
  constant CONV2_LAST_BIAS : std_logic_vector := "100000"; -- quantidade de bias e scale (32)    
  constant CONV2_LAST_ROW : std_logic_vector := "010010"; -- 18 
  constant CONV2_LAST_COL : std_logic_vector := "01110";  -- 14 
  constant CONV2_NC_SEL_WIDTH : integer := 3; -- largura de bits para selecionar saidas dos NCs de cada filtro
  constant CONV2_NC_ADDRESS_WIDTH : integer := 7; -- numero de bits para enderecar NCs 
  constant CONV2_NC_OHE_WIDTH : integer := 96; -- numero de bits para one-hot-encoder de NCs
  constant CONV2_BIAS_OHE_WIDTH : integer := 32; -- numero de bits para one-hot-encoder de bias e scales
  constant CONV2_WEIGHTS_ADDRESS_WIDTH : integer := 10; -- numero de bits para enderecar pesos
  constant CONV2_BIAS_ADDRESS_WIDTH : integer := 6; -- numero de bits para enderecar registradores de bias e scales
  constant CONV2_SCALE_SHIFT : t_ARRAY_OF_INTEGER(0 to CONV2_M-1) := (6,7,6,6,6,7,6,7,6,7,7,6,6,6,7,7);
  constant CONV2_WEIGHTS_FILE_NAME     : string := "conv2.mif";
  constant CONV2_BIAS_FILE_NAME        : string := "conv2_bias.mif";
  ------------------------------------------------------------------
  constant CONV3_H : integer := 10; -- iFMAP Height 
  constant CONV3_W : integer := 8; -- iFMAP Width 
  constant CONV3_C : integer := 16; -- iFMAP Chanels (filter Chanels also)
  constant CONV3_R : integer := 3; -- filter Height 
  constant CONV3_S : integer := 3; -- filter Width     
  constant CONV3_M : integer := 32; -- Number of filters (oFMAP Chanels also)        
  constant CONV3_NUM_PES_FILTER_CHA : std_logic_vector := "1000"; -- quantidade de peso por filtro por canal(R*S) (de 0 a 8)
  constant CONV3_LAST_PES : std_logic_vector := "1100100001000"; -- quantidade de pesos (4608) (13 bits)
  constant CONV3_LAST_BIAS : std_logic_vector := "1000000"; -- quantidade de bias e scale (64)    
  constant CONV3_LAST_ROW : std_logic_vector := "001010"; -- 10
  constant CONV3_LAST_COL : std_logic_vector := "001000"; -- 8
  constant CONV3_NC_SEL_WIDTH : integer := 4; -- largura de bits para selecionar saidas dos NCs de cada filtro
  constant CONV3_NC_ADDRESS_WIDTH : integer := 10; -- numero de bits para enderecar todos os NCs 
  constant CONV3_NC_OHE_WIDTH : integer := 512; -- numero de bits para one-hot-encoder de NCs
  constant CONV3_BIAS_OHE_WIDTH : integer := 64; -- numero de bits para one-hot-encoder de bias e scales
  constant CONV3_WEIGHTS_ADDRESS_WIDTH : integer := 13; -- numero de bits para enderecar pesos
  constant CONV3_BIAS_ADDRESS_WIDTH : integer := 7; -- numero de bits para enderecar registradores de bias e scales
  constant CONV3_SCALE_SHIFT : t_ARRAY_OF_INTEGER(CONV3_M-1 downto 0) := (7 ,8 ,7 ,7 ,8 ,8 ,7 ,7 ,7 ,7 ,7 ,7 ,7 ,7 ,7 ,7 ,7 ,7 ,7 ,7 ,8 ,7 ,7 ,7 ,7 ,7 ,7 ,7 ,8 ,7 ,7 ,7);
  constant CONV3_WEIGHTS_FILE_NAME     : string := "conv3.mif";
  constant CONV3_BIAS_FILE_NAME        : string := "conv3_bias.mif";
  
  
  
  
  -- bloco rom para imagem de entrada  
  component image_chanel IS
    generic
    (
      init_file_name : STRING := "input_chanel_1.mif"
    );
    port
    (
      address	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
      clock		: IN STD_LOGIC  := '1';
      rden		: IN STD_LOGIC  := '1';
      q		    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
  end component;

  --------------------------------------------------------
  -- bloco rebuffer
  component rebuff1 is
    generic (
      ADDR_WIDTH : integer;
      DATA_WIDTH : integer;  
      NUM_BUFFER_LINES   : std_logic_vector(1 downto 0);
      IFMAP_WIDTH : std_logic_vector(5 downto 0);
      IFMAP_HEIGHT : std_logic_vector(5 downto 0); 
      OFMAP_WIDTH : std_logic_vector(5 downto 0);
      OFMAP_HEIGHT : std_logic_vector(5 downto 0);
      PAD_H : std_logic_vector(5 downto 0);
      PAD_W : std_logic_vector(5 downto 0);
      NUM_CHANNELS : integer;
      WITH_PAD : std_logic
    );
    port (
      i_CLK       : in  std_logic;
      i_CLR       : in  std_logic;
      i_GO        : in  std_logic;
      i_DATA      : in  t_ARRAY_OF_LOGIC_VECTOR(0 to NUM_CHANNELS-1)(DATA_WIDTH-1 downto 0);
      o_READ_ENA  : out std_logic;
      o_IN_ADDR   : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
      o_OUT_ADDR  : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
      o_WRITE_ENA : out std_logic;
      o_DATA      : out t_ARRAY_OF_LOGIC_VECTOR(0 to NUM_CHANNELS-1)(DATA_WIDTH-1 downto 0);
      o_SEL_BUFF_LINE  : out std_logic_vector (1 downto 0);
      o_READY     : out std_logic
    );
  end component;
  
  ----------------------------------------------------------  
  
  -- primeira camada convolucional
  component conv1 is
    generic 
    (
      DATA_WIDTH : integer ;
      ADDR_WIDTH : integer ;
      H : integer ;
      W : integer ;
      C : integer ;
      R : integer ;
      S : integer ;
      M : integer ;      
      NUM_PES_FILTER_CHA : std_logic_vector; 
      LAST_PES : std_logic_vector ;
      LAST_BIAS : std_logic_vector ;
      LAST_ROW : std_logic_vector ;
      LAST_COL : std_logic_vector ;
      NC_SEL_WIDTH : integer ;
      NC_ADDRESS_WIDTH : integer ;
      NC_OHE_WIDTH : integer ;
      BIAS_OHE_WIDTH : integer ;
      WEIGHTS_ADDRESS_WIDTH : integer ;
      BIAS_ADDRESS_WIDTH : integer ;
      SCALE_SHIFT  : t_ARRAY_OF_INTEGER;
      WEIGHTS_FILE_NAME : STRING;
      BIAS_FILE_NAME : STRING      
    );
    port 
    (
      i_CLK       : in STD_LOGIC;
      i_CLR       : in STD_LOGIC;
      i_GO        : in STD_LOGIC;
      i_LOAD      : in std_logic;
      o_READY     : out std_logic;
      i_IN_DATA      : in  t_ARRAY_OF_LOGIC_VECTOR(0 to C-1)(DATA_WIDTH-1 downto 0);
      i_IN_WRITE_ENA  : in std_logic;    
      i_IN_SEL_LINE   : in std_logic_vector (1 downto 0); 
      i_IN_WRITE_ADDR : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
      i_OUT_READ_ENA  : in std_logic;
      i_OUT_READ_ADDR : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
      o_OUT_DATA : out t_ARRAY_OF_LOGIC_VECTOR(0 to M-1)(DATA_WIDTH-1 downto 0)
    );
  end component;   

  ---------------------------------------------------
  
  component pool1 is
    generic (    
      DATA_WIDTH   : integer := 8;
      ADDR_WIDTH   : integer := 10;
      NUM_CHANNELS : integer := 6;
      MAX_ADDR : std_logic_vector
    );
    port (
      i_CLK       : in std_logic;
      i_CLR       : in std_logic; 
      i_GO        : in std_logic;
      o_READY     : out std_logic;
      i_IN_DATA        : t_ARRAY_OF_LOGIC_VECTOR(0 to NUM_CHANNELS-1)(DATA_WIDTH-1 downto 0) := (others => (others => '0')) ;
      i_IN_WRITE_ENA   : in std_logic;
      i_IN_WRITE_ADDR  : in std_logic_vector (ADDR_WIDTH - 1 downto 0) := (others => '0');
      i_IN_SEL_LINE    : in std_logic_vector (1 downto 0);
      i_OUT_READ_ADDR0  : in std_logic_vector (ADDR_WIDTH - 1 downto 0) := (others => '0');
      o_BUFFER_OUT : out t_ARRAY_OF_LOGIC_VECTOR(0 to NUM_CHANNELS-1)(DATA_WIDTH-1 downto 0) := (others => (others => '0'))    
    );
  end component;
  
    
  ---------------------------------------------------------   
  
  
  --------------- sinais rebuff1  
  -- dado de entrada
  signal w_REBUFF1_DATA_IN      : t_ARRAY_OF_LOGIC_VECTOR(0 to 2)(DATA_WIDTH-1 downto 0);
  -- habilita leitura
  signal w_IMG_READ_ENA  :  std_logic;
  -- endereco a ser lido
  signal w_IMG_READ_ADDR   :  std_logic_vector (ADDR_WIDTH - 1 downto 0);
  -- endereco a ser escrito
  signal w_REBUFF1_WRITE_ADDR  :  std_logic_vector (ADDR_WIDTH - 1 downto 0);
  -- habilita escrita    
  signal w_REBUFF1_WRITE_ENA :  std_logic;
  -- dado de saida (mesmo q o de entrada)
  signal w_REBUFF1_DATA_OUT      :  t_ARRAY_OF_LOGIC_VECTOR(0 to 2)(DATA_WIDTH-1 downto 0);
  -- linha de buffer selecionada
  signal w_REBUFF1_SEL_LINE   :  std_logic_vector (1 downto 0);   
  -- sinal ready reuffer 1
  signal w_REBUFF1_READY     :  std_logic;
  
    
  -------- SINAIS CONV1
  signal w_COVN1_GO        : STD_LOGIC;
  signal w_COVN1_LOAD      : std_logic;
  signal w_COVN1_READY     : std_logic;  
  --------------------------------------------------  
  
  -- saida dos buffers de saida da conv1
  signal w_CONV1_DATA_OUT : t_ARRAY_OF_LOGIC_VECTOR(0 to 5)(DATA_WIDTH-1 downto 0) := (others => (others => '0'));
  
  --------------- sinais rebuff2    
  -- habilita leitura
  signal w_REBUFF2_READ_ENA  :  std_logic;
  -- endereco a ser lido
  signal w_REBUFF2_READ_ADDR   :  std_logic_vector (ADDR_WIDTH - 1 downto 0);
  -- endereco a ser escrito
  signal w_REBUFF2_WRITE_ADDR  :  std_logic_vector (ADDR_WIDTH - 1 downto 0);
  -- habilita escrita    
  signal w_REBUFF2_WRITE_ENA :  std_logic;  
  -- linha de buffer selecionada
  signal w_REBUFF2_SEL_LINE   :  std_logic_vector (1 downto 0); 
  -- sinal ready reuffer 1
  signal w_REBUFF2_READY     :  std_logic;
  
  -- sinais pool1
  -- saida rebbufer2 entrada pool1
  signal w_POOL1_READY : std_logic;
  signal w_POOL1_DATA_IN : t_ARRAY_OF_LOGIC_VECTOR(0 to 5)(DATA_WIDTH-1 downto 0) := (others => (others => '0'));
  signal w_POOL1_DATA_OUT : t_ARRAY_OF_LOGIC_VECTOR(0 to 5)(DATA_WIDTH-1 downto 0) := (others => (others => '0'));
  
  
  -- sinais rebuffer 3
  -- habilita leitura
  signal w_REBUFF3_READ_ENA  :  std_logic;
  -- endereco a ser lido
  signal w_REBUFF3_READ_ADDR   :  std_logic_vector (ADDR_WIDTH - 1 downto 0) := (others => '0');
  -- endereco a ser escrito
  signal w_REBUFF3_WRITE_ADDR  :  std_logic_vector (ADDR_WIDTH - 1 downto 0);
  -- habilita escrita    
  signal w_REBUFF3_WRITE_ENA :  std_logic;  
  -- linha de buffer selecionada
  signal w_REBUFF3_SEL_LINE   :  std_logic_vector (1 downto 0); 
  -- sinal ready rebuffer 3
  signal w_REBUFF3_READY     :  std_logic;
  
  
  -- sinais conv2
  signal w_CONV2_DATA_IN : t_ARRAY_OF_LOGIC_VECTOR(0 to 5)(DATA_WIDTH-1 downto 0) := (others => (others => '0'));  
  signal w_CONV2_DATA_OUT : t_ARRAY_OF_LOGIC_VECTOR(0 to 15)(DATA_WIDTH-1 downto 0) := (others => (others => '0')); 
  signal w_CONV2_READY : std_logic;
  
  -- sinais rebuffer4
  -- habilita leitura
  signal w_REBUFF4_READ_ENA  :  std_logic := '0';
  -- endereco a ser lido
  signal w_REBUFF4_READ_ADDR   :  std_logic_vector (ADDR_WIDTH - 1 downto 0) := (others => '0');
  -- endereco a ser escrito
  signal w_REBUFF4_WRITE_ADDR  :  std_logic_vector (ADDR_WIDTH - 1 downto 0);
  -- habilita escrita    
  signal w_REBUFF4_WRITE_ENA :  std_logic;  
  -- linha de buffer selecionada
  signal w_REBUFF4_SEL_LINE   :  std_logic_vector (1 downto 0); 
  -- sinal ready rebuffer 3
  signal w_REBUFF4_READY     :  std_logic;
 
  -- sinais pool2
  signal w_POOL2_DATA_IN : t_ARRAY_OF_LOGIC_VECTOR(0 to 15)(DATA_WIDTH-1 downto 0) := (others => (others => '0')); 
  signal w_POOL2_DATA_OUT : t_ARRAY_OF_LOGIC_VECTOR(0 to 15)(DATA_WIDTH-1 downto 0) := (others => (others => '0')); 
  signal w_POOL2_READY : std_logic;
  
  
  -- sinais rebuffer5
  -- habilita leitura
  signal w_REBUFF5_READ_ENA  :  std_logic := '0';
  -- endereco a ser lido
  signal w_REBUFF5_READ_ADDR   :  std_logic_vector (ADDR_WIDTH - 1 downto 0) := (others => '0');
  -- endereco a ser escrito
  signal w_REBUFF5_WRITE_ADDR  :  std_logic_vector (ADDR_WIDTH - 1 downto 0);
  -- habilita escrita    
  signal w_REBUFF5_WRITE_ENA :  std_logic;  
  -- linha de buffer selecionada
  signal w_REBUFF5_SEL_LINE   :  std_logic_vector (1 downto 0); 
  -- sinal ready rebuffer 3
  signal w_REBUFF5_READY     :  std_logic;
 
    
  -- sinais conv3
  signal w_CONV3_DATA_IN : t_ARRAY_OF_LOGIC_VECTOR(0 to 15)(DATA_WIDTH-1 downto 0) := (others => (others => '0'));  
  signal w_CONV3_DATA_OUT : t_ARRAY_OF_LOGIC_VECTOR(0 to 31)(DATA_WIDTH-1 downto 0) := (others => (others => '0')); 
  signal w_CONV3_READY : std_logic;
   
 
  -- sinais rebuffer6
  -- habilita leitura
  signal w_REBUFF6_READ_ENA  :  std_logic := '0';
  -- endereco a ser lido
  signal w_REBUFF6_READ_ADDR   :  std_logic_vector (ADDR_WIDTH - 1 downto 0) := (others => '0');
  -- endereco a ser escrito
  signal w_REBUFF6_WRITE_ADDR  :  std_logic_vector (ADDR_WIDTH - 1 downto 0);
  -- habilita escrita    
  signal w_REBUFF6_WRITE_ENA :  std_logic;  
  -- linha de buffer selecionada
  signal w_REBUFF6_SEL_LINE   :  std_logic_vector (1 downto 0); 
  -- sinal ready rebuffer 
  signal w_REBUFF6_READY     :  std_logic;
    
    
begin
  
  -- imagem de entrada
  u_IMG_CHA_0 : image_chanel
                  generic map ("input_chanel_R.mif")
                  port map (
                    address	=> w_IMG_READ_ADDR,
                    clock		=> i_CLK,
                    rden		=> w_IMG_READ_ENA,
                    q		    => w_REBUFF1_DATA_IN(0)
                  );
                  
  -- imagem de entrada
  u_IMG_CHA_1 : image_chanel
                  generic map ("input_chanel_G.mif")
                  port map (
                    address	=> w_IMG_READ_ADDR,
                    clock		=> i_CLK,
                    rden		=> w_IMG_READ_ENA,
                    q		    => w_REBUFF1_DATA_IN(1)
                  );
  -- imagem de entrada
  u_IMG_CHA_2 : image_chanel
                  generic map ("input_chanel_B.mif")
                  port map (
                    address	=> w_IMG_READ_ADDR,
                    clock		=> i_CLK,
                    rden		=> w_IMG_READ_ENA,
                    q		    => w_REBUFF1_DATA_IN(2)
                  );
                  
  ------------------------------------------------------
  u_REBUFF_1 : rebuff1 
                  generic map 
                  (
                    ADDR_WIDTH    => 10,
                    DATA_WIDTH    => 8 ,  
                    NUM_BUFFER_LINES => "11"    , -- 3 buffers
                    IFMAP_WIDTH   => "011000", -- 24
                    IFMAP_HEIGHT  => "100000", -- 32
                    OFMAP_WIDTH   => "011010", -- 26
                    OFMAP_HEIGHT  => "100010", -- 34
                    PAD_H         => "100001", -- 33 (indice para adicionar pad linha de baixo)
                    PAD_W         => "011001",  -- 25 (indice para adicionar pad coluna da direita)
                    NUM_CHANNELS  => 3,
                    WITH_PAD      => '1'
                  )
                  port map 
                  (
                    i_CLK       => i_CLK,
                    i_CLR       => i_CLR,
                    i_GO        => i_GO,
                    i_DATA      => w_REBUFF1_DATA_IN,
                    o_READ_ENA  => w_IMG_READ_ENA,
                    o_IN_ADDR   => w_IMG_READ_ADDR,
                    o_OUT_ADDR  => w_REBUFF1_WRITE_ADDR,
                    o_WRITE_ENA => w_REBUFF1_WRITE_ENA,
                    o_DATA      => w_REBUFF1_DATA_OUT,
                    o_SEL_BUFF_LINE  => w_REBUFF1_SEL_LINE,
                    o_READY     => w_REBUFF1_READY
                  );
  ------------------------------------------------------
	u_CONV1 : conv1 
    generic map
    (
      DATA_WIDTH            => DATA_WIDTH            ,
      ADDR_WIDTH            => ADDR_WIDTH            ,
      H                     => CONV1_H                     ,
      W                     => CONV1_W                     ,
      C                     => CONV1_C                     ,
      R                     => CONV1_R                     ,
      S                     => CONV1_S                     ,
      M                     => CONV1_M                     ,
      NUM_PES_FILTER_CHA    => CONV1_NUM_PES_FILTER_CHA    ,
      LAST_PES              => CONV1_LAST_PES              ,
      LAST_BIAS             => CONV1_LAST_BIAS             ,
      LAST_ROW              => CONV1_LAST_ROW              ,
      LAST_COL              => CONV1_LAST_COL              ,
      NC_SEL_WIDTH          => CONV1_NC_SEL_WIDTH          ,
      NC_ADDRESS_WIDTH      => CONV1_NC_ADDRESS_WIDTH      ,
      NC_OHE_WIDTH          => CONV1_NC_OHE_WIDTH          ,
      BIAS_OHE_WIDTH        => CONV1_BIAS_OHE_WIDTH        ,
      WEIGHTS_ADDRESS_WIDTH => CONV1_WEIGHTS_ADDRESS_WIDTH ,
      BIAS_ADDRESS_WIDTH    => CONV1_BIAS_ADDRESS_WIDTH    ,
      SCALE_SHIFT           => CONV1_SCALE_SHIFT           ,
      WEIGHTS_FILE_NAME     => CONV1_WEIGHTS_FILE_NAME     ,
      BIAS_FILE_NAME        => CONV1_BIAS_FILE_NAME        
    )
    port map
    (
      i_CLK           => i_CLK  ,
      i_CLR           => i_CLR  ,
      i_GO            => w_REBUFF1_READY ,     
      i_LOAD          => i_LOAD         , 
      o_READY         => w_COVN1_READY  , 
      i_IN_DATA       => w_REBUFF1_DATA_OUT,
      i_IN_WRITE_ENA  => w_REBUFF1_WRITE_ENA,
      i_IN_SEL_LINE   => w_REBUFF1_SEL_LINE,
      i_IN_WRITE_ADDR => w_REBUFF1_WRITE_ADDR,
      i_OUT_READ_ENA  => w_REBUFF2_READ_ENA  ,
      i_OUT_READ_ADDR => w_REBUFF2_READ_ADDR ,
      o_OUT_DATA      => w_CONV1_DATA_OUT
		);
  
  ------------------------------------------------------  
           
   u_REBUFF_2 : rebuff1 
                   generic map 
                   (
                     ADDR_WIDTH    => 10,
                     DATA_WIDTH    => 8,  
                     NUM_BUFFER_LINES => "10"    , -- 2 buffers
                     IFMAP_WIDTH   => "011000", -- 24
                     IFMAP_HEIGHT  => "100000", -- 32
                     OFMAP_WIDTH   => "011000", -- 24
                     OFMAP_HEIGHT  => "100000", -- 32
                     PAD_H         => "000000", -- sem pad
                     PAD_W         => "000000", -- sem pad
                     NUM_CHANNELS  => 6,    
                     WITH_PAD      => '0'
                   )
                   port map 
                   (
                     i_CLK       => i_CLK,
                     i_CLR       => i_CLR,
                     i_GO        => w_COVN1_READY,
                     i_DATA      => w_CONV1_DATA_OUT,
                     o_READ_ENA  => w_REBUFF2_READ_ENA,
                     o_IN_ADDR   => w_REBUFF2_READ_ADDR,
                     o_OUT_ADDR  => w_REBUFF2_WRITE_ADDR,
                     o_WRITE_ENA => w_REBUFF2_WRITE_ENA,
                     o_DATA      => w_POOL1_DATA_IN,
                     o_SEL_BUFF_LINE  => w_REBUFF2_SEL_LINE,
                     o_READY     => w_REBUFF2_READY
                   );
  

  -------------------------------------------------------
  
  u_POOL1 : pool1 
                  generic map (    
                    DATA_WIDTH   => 8,
                    ADDR_WIDTH   => 10,
                    NUM_CHANNELS => 6,
                    MAX_ADDR     => "0110000000"
                  )
                  port map (
                    i_CLK       => i_CLK,
                    i_CLR       => i_CLR,
                    i_GO        => w_REBUFF2_READY,
                    o_READY     => w_POOL1_READY,
                    i_IN_DATA        => w_POOL1_DATA_IN,
                    i_IN_WRITE_ENA   => w_REBUFF2_WRITE_ENA,
                    i_IN_WRITE_ADDR  => w_REBUFF2_WRITE_ADDR,
                    i_IN_SEL_LINE    => w_REBUFF2_SEL_LINE,
                    i_OUT_READ_ADDR0 => w_REBUFF3_READ_ADDR,
                    o_BUFFER_OUT     => w_POOL1_DATA_OUT
                  );
  
  -------------------------------------------------------
  
  u_REBUFF_3 : rebuff1 
                  generic map (
                    ADDR_WIDTH       => 10,
                    DATA_WIDTH       => 8,
                    NUM_BUFFER_LINES => "11",
                    IFMAP_WIDTH      => "001100",
                    IFMAP_HEIGHT     => "010000",
                    OFMAP_WIDTH      => "001110",
                    OFMAP_HEIGHT     => "010010",
                    PAD_W            => "001101",
                    PAD_H            => "010001",
                    NUM_CHANNELS     => 6,
                    WITH_PAD         => '1'
                  )
                  port map (
                    i_CLK           => i_CLK,
                    i_CLR           => i_CLR,
                    i_GO            => w_POOL1_READY,
                    i_DATA          => w_POOL1_DATA_OUT,
                    o_READ_ENA      => w_REBUFF3_READ_ENA,
                    o_IN_ADDR       => w_REBUFF3_READ_ADDR,
                    o_OUT_ADDR      => w_REBUFF3_WRITE_ADDR,
                    o_WRITE_ENA     => w_REBUFF3_WRITE_ENA,
                    o_DATA          => w_CONV2_DATA_IN,
                    o_SEL_BUFF_LINE => w_REBUFF3_SEL_LINE,
                    o_READY         => w_REBUFF3_READY
                  );
   
  -------------------------------------------------------
  
  
  u_CONV2 : conv1 
                generic map
                (
                  DATA_WIDTH            => DATA_WIDTH            ,
                  ADDR_WIDTH            => ADDR_WIDTH            ,
                  H                     => CONV2_H                     ,
                  W                     => CONV2_W                     ,
                  C                     => CONV2_C                     ,
                  R                     => CONV2_R                     ,
                  S                     => CONV2_S                     ,
                  M                     => CONV2_M                     ,
                  NUM_PES_FILTER_CHA    => CONV2_NUM_PES_FILTER_CHA    ,
                  LAST_PES              => CONV2_LAST_PES              ,
                  LAST_BIAS             => CONV2_LAST_BIAS             ,
                  LAST_ROW              => CONV2_LAST_ROW              ,
                  LAST_COL              => CONV2_LAST_COL              ,
                  NC_SEL_WIDTH          => CONV2_NC_SEL_WIDTH          ,
                  NC_ADDRESS_WIDTH      => CONV2_NC_ADDRESS_WIDTH      ,
                  NC_OHE_WIDTH          => CONV2_NC_OHE_WIDTH          ,
                  BIAS_OHE_WIDTH        => CONV2_BIAS_OHE_WIDTH        ,
                  WEIGHTS_ADDRESS_WIDTH => CONV2_WEIGHTS_ADDRESS_WIDTH ,
                  BIAS_ADDRESS_WIDTH    => CONV2_BIAS_ADDRESS_WIDTH    ,
                  SCALE_SHIFT           => CONV2_SCALE_SHIFT           ,
                  WEIGHTS_FILE_NAME     => CONV2_WEIGHTS_FILE_NAME     ,
                  BIAS_FILE_NAME        => CONV2_BIAS_FILE_NAME        
                )
                port map
                (
                  i_CLK           => i_CLK,
                  i_CLR           => i_CLR,
                  i_GO            => w_REBUFF3_READY,
                  i_LOAD          => i_LOAD,
                  o_READY         => w_CONV2_READY,
                  i_IN_DATA       => w_CONV2_DATA_IN,
                  i_IN_WRITE_ENA  => w_REBUFF3_WRITE_ENA,
                  i_IN_SEL_LINE   => w_REBUFF3_SEL_LINE,
                  i_IN_WRITE_ADDR => w_REBUFF3_WRITE_ADDR,
                  i_OUT_READ_ENA  => w_REBUFF4_READ_ENA,
                  i_OUT_READ_ADDR => w_REBUFF4_READ_ADDR,
                  o_OUT_DATA      => w_CONV2_DATA_OUT
                );
  
  -------------------------------------------------------
  
    
  u_REBUFF_4 : rebuff1 
                  generic map (
                    ADDR_WIDTH       => 10,
                    DATA_WIDTH       => 8,
                    NUM_BUFFER_LINES => "10",
                    IFMAP_WIDTH      => "001100",
                    IFMAP_HEIGHT     => "010000",
                    OFMAP_WIDTH      => "001100",
                    OFMAP_HEIGHT     => "010000",
                    PAD_W            => "000000",
                    PAD_H            => "000000",
                    NUM_CHANNELS     => 16,
                    WITH_PAD         => '0'
                  )
                  port map (
                    i_CLK           => i_CLK,
                    i_CLR           => i_CLR,
                    i_GO            => w_CONV2_READY,
                    i_DATA          => w_CONV2_DATA_OUT,
                    o_READ_ENA      => w_REBUFF4_READ_ENA,
                    o_IN_ADDR       => w_REBUFF4_READ_ADDR,
                    o_OUT_ADDR      => w_REBUFF4_WRITE_ADDR,
                    o_WRITE_ENA     => w_REBUFF4_WRITE_ENA,
                    o_DATA          => w_POOL2_DATA_IN,
                    o_SEL_BUFF_LINE => w_REBUFF4_SEL_LINE,
                    o_READY         => w_REBUFF4_READY
                  );
   
  -------------------------------------------------------
  
  u_POOL2 : pool1 
                  generic map (    
                    DATA_WIDTH   => 8,
                    ADDR_WIDTH   => 10,
                    NUM_CHANNELS => 16,
                    MAX_ADDR     => "0011000000"
                  )
                  port map (
                    i_CLK       => i_CLK,
                    i_CLR       => i_CLR,
                    i_GO        => w_REBUFF4_READY,
                    o_READY     => w_POOL2_READY,
                    i_IN_DATA        => w_POOL2_DATA_IN,
                    i_IN_WRITE_ENA   => w_REBUFF4_WRITE_ENA,
                    i_IN_WRITE_ADDR  => w_REBUFF4_WRITE_ADDR,
                    i_IN_SEL_LINE    => w_REBUFF4_SEL_LINE,
                    i_OUT_READ_ADDR0 => w_REBUFF5_READ_ADDR,
                    o_BUFFER_OUT     => w_POOL2_DATA_OUT
                  );
   
  -------------------------------------------------------
  
    
  u_REBUFF_5 : rebuff1 
                  generic map (
                    ADDR_WIDTH       => 10,
                    DATA_WIDTH       => 8,
                    NUM_BUFFER_LINES => "10",
                    IFMAP_WIDTH      => "000110",
                    IFMAP_HEIGHT     => "001000",
                    OFMAP_WIDTH      => "001000",
                    OFMAP_HEIGHT     => "001010",
                    PAD_W            => "000000",
                    PAD_H            => "000000",
                    NUM_CHANNELS     => 16,
                    WITH_PAD         => '1'
                  )
                  port map (
                    i_CLK           => i_CLK,
                    i_CLR           => i_CLR,
                    i_GO            => w_POOL2_READY,
                    i_DATA          => w_POOL2_DATA_OUT,
                    o_READ_ENA      => w_REBUFF5_READ_ENA,
                    o_IN_ADDR       => w_REBUFF5_READ_ADDR,
                    o_OUT_ADDR      => w_REBUFF5_WRITE_ADDR,
                    o_WRITE_ENA     => w_REBUFF5_WRITE_ENA,
                    o_DATA          => w_CONV3_DATA_IN,
                    o_SEL_BUFF_LINE => w_REBUFF5_SEL_LINE,
                    o_READY         => w_REBUFF5_READY
                  );
   
  -------------------------------------------------------
  
  u_CONV3 : conv1 
                generic map
                (
                  DATA_WIDTH            => DATA_WIDTH            ,
                  ADDR_WIDTH            => ADDR_WIDTH            ,
                  H                     => CONV3_H                     ,
                  W                     => CONV3_W                     ,
                  C                     => CONV3_C                     ,
                  R                     => CONV3_R                     ,
                  S                     => CONV3_S                     ,
                  M                     => CONV3_M                     ,
                  NUM_PES_FILTER_CHA    => CONV3_NUM_PES_FILTER_CHA    ,
                  LAST_PES              => CONV3_LAST_PES              ,
                  LAST_BIAS             => CONV3_LAST_BIAS             ,
                  LAST_ROW              => CONV3_LAST_ROW              ,
                  LAST_COL              => CONV3_LAST_COL              ,
                  NC_SEL_WIDTH          => CONV3_NC_SEL_WIDTH          ,
                  NC_ADDRESS_WIDTH      => CONV3_NC_ADDRESS_WIDTH      ,
                  NC_OHE_WIDTH          => CONV3_NC_OHE_WIDTH          ,
                  BIAS_OHE_WIDTH        => CONV3_BIAS_OHE_WIDTH        ,
                  WEIGHTS_ADDRESS_WIDTH => CONV3_WEIGHTS_ADDRESS_WIDTH ,
                  BIAS_ADDRESS_WIDTH    => CONV3_BIAS_ADDRESS_WIDTH    ,
                  SCALE_SHIFT           => CONV3_SCALE_SHIFT           ,
                  WEIGHTS_FILE_NAME     => CONV3_WEIGHTS_FILE_NAME     ,
                  BIAS_FILE_NAME        => CONV3_BIAS_FILE_NAME        
                )
                port map
                (
                  i_CLK           => i_CLK,
                  i_CLR           => i_CLR,
                  i_GO            => w_REBUFF5_READY,
                  i_LOAD          => i_LOAD,
                  o_READY         => w_CONV3_READY,
                  i_IN_DATA       => w_CONV3_DATA_IN,
                  i_IN_WRITE_ENA  => w_REBUFF5_WRITE_ENA,
                  i_IN_SEL_LINE   => w_REBUFF5_SEL_LINE,
                  i_IN_WRITE_ADDR => w_REBUFF5_WRITE_ADDR,
                  i_OUT_READ_ENA  => w_REBUFF6_READ_ENA,
                  i_OUT_READ_ADDR => w_REBUFF6_READ_ADDR,
                  o_OUT_DATA      => w_CONV3_DATA_OUT
                );
  

  o_READY <= w_CONV3_READY;
end arch;
  


  