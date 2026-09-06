DROP DATABASE IF EXISTS stockflow;
CREATE DATABASE stockflow;
USE stockflow;

CREATE TABLE cargos (
  id int NOT NULL AUTO_INCREMENT,
  nome varchar(255) NOT NULL,
  descricao varchar(255) DEFAULT NULL,
  criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cargos VALUES
(1,'Administrador','Cargo com acesso total ao sistema','2026-04-14 00:51:33');

CREATE TABLE permissoes (
  id int NOT NULL AUTO_INCREMENT,
  nome varchar(255) NOT NULL,
  descricao varchar(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO permissoes VALUES
(1,'GERENCIAR_USUARIOS','Permite gerenciar usuarios do sistema'),
(2,'GERENCIAR_CARGOS','Permite gerenciar cargos do sistema'),
(3,'CADASTRAR_ITENS','Permite cadastrar novos itens no estoque'),
(4,'EDITAR_ITENS','Permite editar itens do estoque'),
(5,'EXCLUIR_ITENS','Permite excluir ou inativar itens do estoque'),
(6,'REGISTRAR_ENTRADA','Permite registrar entradas de estoque'),
(7,'REGISTRAR_SAIDA','Permite registrar saidas de estoque'),
(8,'VER_RELATORIOS','Permite visualizar relatorios do sistema');

CREATE TABLE cargo_permissoes (
  cargo_id int NOT NULL,
  permissao_id int NOT NULL,
  PRIMARY KEY (cargo_id, permissao_id),
  KEY fk_cargo_permissoes_permissao (permissao_id),
  CONSTRAINT fk_cargo_permissoes_cargo FOREIGN KEY (cargo_id) REFERENCES cargos (id),
  CONSTRAINT fk_cargo_permissoes_permissao FOREIGN KEY (permissao_id) REFERENCES permissoes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cargo_permissoes VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8);

CREATE TABLE unidades (
  id int NOT NULL AUTO_INCREMENT,
  nome varchar(255) NOT NULL,
  abreviacao varchar(255) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO unidades VALUES
(1,'Unidade','UN'),
(2,'Par','PR'),
(3,'Metro','M');

CREATE TABLE categorias (
  id int NOT NULL AUTO_INCREMENT,
  nome varchar(255) NOT NULL,
  criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO categorias VALUES
(1,'Som Automotivo','2026-06-08 00:17:33'),
(2,'Baterias','2026-06-08 00:17:33'),
(3,'Cabos e Conectores','2026-06-08 00:17:33'),
(4,'Iluminacao','2026-06-08 00:17:33');

CREATE TABLE usuarios (
  id int NOT NULL AUTO_INCREMENT,
  cargo_id int NOT NULL,
  nome varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  senha_hash varchar(2000) NOT NULL,
  ativo tinyint(1) NOT NULL DEFAULT '1',
  ultimo_acesso datetime DEFAULT NULL,
  criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY email (email),
  KEY fk_usuarios_cargo (cargo_id),
  CONSTRAINT fk_usuarios_cargo FOREIGN KEY (cargo_id) REFERENCES cargos (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO usuarios VALUES
(1,1,'ADM','adm@email.com','$2a$10$FsYqdmjvhmmXTShZNqhGt.g8HHniASRM49aw5FP0GKKD1T0T4Rlkq',1,'2026-04-14 00:58:47','2026-04-14 00:51:41');

CREATE TABLE itens (
  id int NOT NULL AUTO_INCREMENT,
  categoria_id int NOT NULL,
  unidade_id int NOT NULL,
  nome varchar(255) NOT NULL,
  quantidade_atual int NOT NULL DEFAULT '0',
  quantidade_minima int NOT NULL DEFAULT '0',
  preco_custo double DEFAULT NULL,
  preco_venda double DEFAULT NULL,
  ativo tinyint(1) NOT NULL DEFAULT '1',
  criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY fk_itens_categoria (categoria_id),
  KEY fk_itens_unidade (unidade_id),
  CONSTRAINT fk_itens_categoria FOREIGN KEY (categoria_id) REFERENCES categorias (id),
  CONSTRAINT fk_itens_unidade FOREIGN KEY (unidade_id) REFERENCES unidades (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO itens VALUES
(1,1,1,'Modulo Amplificador 400W',8,3,180,320,1,'2026-06-08 00:17:33','2026-06-08 00:17:33'),
(2,1,2,'Alto-falante 6x9 200W',4,2,95,170,1,'2026-06-08 00:17:33','2026-06-08 00:17:33'),
(3,1,1,'Subwoofer 12\" 600W',2,2,230,420,1,'2026-06-08 00:17:33','2026-06-08 00:17:33'),
(4,2,1,'Bateria 60Ah',1,3,310,520,1,'2026-06-08 00:17:33','2026-06-08 00:17:33'),
(5,3,3,'Cabo RCA 5m',15,5,12,25,1,'2026-06-08 00:17:33','2026-06-08 00:17:33'),
(6,4,1,'Strobo LED RGB',0,2,45,89,1,'2026-06-08 00:17:33','2026-06-08 00:17:33'),
(7,1,1,'Tweeters Triaxial 120W',6,2,55,95,0,'2026-06-08 00:17:33','2026-06-08 00:17:33');

CREATE TABLE itens_seq (
  next_val bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO itens_seq VALUES (1);

CREATE TABLE movimentacoes (
  id int NOT NULL AUTO_INCREMENT,
  item_id int NOT NULL,
  usuario_id int NOT NULL,
  tipo varchar(20) NOT NULL,
  quantidade int NOT NULL,
  estoque_antes int NOT NULL,
  estoque_depois int NOT NULL,
  data date NOT NULL,
  observacao varchar(255) DEFAULT NULL,
  criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY fk_movimentacoes_item (item_id),
  KEY fk_movimentacoes_usuario (usuario_id),
  CONSTRAINT fk_movimentacoes_item FOREIGN KEY (item_id) REFERENCES itens (id),
  CONSTRAINT fk_movimentacoes_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
  CONSTRAINT chk_movimentacoes_tipo CHECK ((tipo in ('entrada','saida')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO movimentacoes VALUES
(1,1,1,'entrada',5,3,8,'2026-04-15','Compra fornecedor NF 1042','2026-06-08 00:17:33');

CREATE TABLE nota_entrada (
  id int NOT NULL AUTO_INCREMENT,
  movimentacao_id int NOT NULL,
  tipo varchar(20) NOT NULL,
  nome_arquivo varchar(255) NOT NULL,
  caminho varchar(500) NOT NULL,
  mime_type varchar(100) DEFAULT NULL,
  tamanho_bytes int DEFAULT NULL,
  criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY fk_nota_entrada_movimentacao (movimentacao_id),
  CONSTRAINT fk_nota_entrada_movimentacao FOREIGN KEY (movimentacao_id) REFERENCES movimentacoes (id),
  CONSTRAINT chk_nota_entrada_tipo CHECK ((tipo in ('imagem','nota_fiscal')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO nota_entrada VALUES
(1,1,'nota_fiscal','nf-1042.pdf','notas-entrada/exemplo-nf-1042.pdf','application/pdf',204800,'2026-06-08 00:17:33'),
(2,1,'imagem','recibo.jpg','notas-entrada/exemplo-recibo.jpg','image/jpeg',81920,'2026-06-08 00:17:33');

CREATE TABLE alertas (
  id int NOT NULL AUTO_INCREMENT,
  item_id int NOT NULL,
  tipo varchar(30) NOT NULL,
  visualizado tinyint(1) NOT NULL DEFAULT '0',
  criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY fk_alertas_item (item_id),
  CONSTRAINT fk_alertas_item FOREIGN KEY (item_id) REFERENCES itens (id),
  CONSTRAINT chk_alertas_tipo CHECK ((tipo in ('estoque_baixo','zerado')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE imagem_produto (
  id int NOT NULL AUTO_INCREMENT,
  item_id int NOT NULL,
  nome_arquivo varchar(255) NOT NULL,
  caminho varchar(500) NOT NULL,
  mime_type varchar(100) NOT NULL,
  tamanho_bytes int DEFAULT NULL,
  criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY fk_imagem_produto_item (item_id),
  CONSTRAINT fk_imagem_produto_item FOREIGN KEY (item_id) REFERENCES itens (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO imagem_produto VALUES
(1,1,'amplificador-frente.jpg','imagens-produto/exemplo-amplificador-frente.jpg','image/jpeg',102400,'2026-06-08 00:17:33'),
(2,1,'amplificador-traseira.jpg','imagens-produto/exemplo-amplificador-traseira.jpg','image/jpeg',98304,'2026-06-08 00:17:33'),
(3,5,'cabo-rca.png','imagens-produto/exemplo-cabo-rca.png','image/png',51200,'2026-06-08 00:17:33');

CREATE TABLE vw_alertas_estoque (
  item_id int NOT NULL,
  data_ocorrencia datetime(6) DEFAULT NULL,
  item_nome varchar(255) DEFAULT NULL,
  quantidade_atual int DEFAULT NULL,
  quantidade_minima int DEFAULT NULL,
  tipo_alerta varchar(255) DEFAULT NULL,
  PRIMARY KEY (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;