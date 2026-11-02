-- Original data from the six CSVs. IDs, prices, and dates preserved.
-- Empty fields become NULL; is_active 0/1 becomes BOOLEAN; specs becomes JSONB.
-- Initial load: do not run again on already populated tables.
BEGIN;
SET LOCAL standard_conforming_strings = on;

-- categories: 9 records.
INSERT INTO public.categories (category_id, name, description) VALUES
(1, 'Guitarras', 'Guitarras elétricas de todos os estilos, do rock ao jazz'),
(2, 'Baixos', 'Baixos elétricos e acústicos para todas as formações'),
(3, 'Baterias e Percussão', 'Baterias acústicas, eletrônicas e peças avulsas de percussão'),
(4, 'Teclados e Pianos', 'Pianos digitais, sintetizadores, arranjadores e controladores MIDI'),
(5, 'Violões', 'Violões clássicos, folk e eletroacústicos'),
(6, 'Instrumentos de Sopro (Madeiras)', 'Flautas, clarinetes, saxofones, oboés e outros instrumentos de sopro em madeira'),
(7, 'Instrumentos de Sopro (Metais)', 'Trompetes, trombones, tubas, trompas e outros metais'),
(8, 'Cordas Orquestrais', 'Violinos, violas, violoncelos e contrabaixos acústicos'),
(9, 'Ukuleles', 'Ukuleles soprano, concert, tenor e barítono');

-- customers: 50 records.
INSERT INTO public.customers (customer_id, name, phone, email, city) VALUES
(1, 'Lucas Mendes da Silva', '(67) 99812-3456', 'lucas.mendes@jmail.com', 'Campo Grande'),
(2, 'Ana Carolina Ferreira', '(67) 99654-7821', 'anacarol.ferreira@coldmail.com', 'Campo Grande'),
(3, 'Pedro Henrique Oliveira', '(67) 98432-1098', 'pedro.oliveira@jmail.com', 'Campo Grande'),
(4, 'Mariana Costa Santos', '(67) 99123-4567', 'mariana.costa@inlook.com', 'Campo Grande'),
(5, 'Rafael Augusto Pereira', '(67) 98765-4321', 'rafael.pereira@jmail.com', 'Campo Grande'),
(6, 'Juliana Almeida Rodrigues', '(67) 99234-5678', 'juliana.almeida@hayoo.com.br', 'Campo Grande'),
(7, 'Thiago Barbosa Lima', '(67) 98321-6543', 'thiago.barbosa@jmail.com', 'Campo Grande'),
(8, 'Fernanda Ribeiro Souza', '(67) 99456-7890', 'fernanda.ribeiro@coldmail.com', 'Campo Grande'),
(9, 'Gabriel Santos Araújo', '(67) 98654-3210', 'gabriel.araujo@jmail.com', 'Dourados'),
(10, 'Camila Duarte Nascimento', '(67) 99567-8901', 'camila.duarte@inlook.com', 'Campo Grande'),
(11, 'Bruno Carvalho Martins', '(67) 98543-2109', 'bruno.martins@jmail.com', 'Três Lagoas'),
(12, 'Isabela Moreira Cunha', '(67) 99678-9012', 'isabela.moreira@jmail.com', 'Campo Grande'),
(13, 'Diego Fernandes Castro', '(67) 98210-9876', 'diego.castro@coldmail.com', 'Campo Grande'),
(14, 'Letícia Gonçalves Rocha', '(67) 99789-0123', 'leticia.rocha@jmail.com', 'Campo Grande'),
(15, 'Matheus Ramos Correia', '(67) 98109-8765', 'matheus.correia@hayoo.com.br', 'Corumbá'),
(16, 'Patrícia Vieira Cardoso', '(67) 99890-1234', 'patricia.cardoso@jmail.com', 'Campo Grande'),
(17, 'Gustavo Teixeira Nunes', '(67) 98098-7654', 'gustavo.nunes@inlook.com', 'Ponta Porã'),
(18, 'Aline Borges Monteiro', '(67) 99901-2345', 'aline.monteiro@jmail.com', 'Campo Grande'),
(19, 'Rodrigo Silva', '(67) 99111-2222', 'rodrigo.silva@jmail.com', 'Campo Grande'),
(20, 'Amanda Lima', '(67) 99222-3333', 'amanda.lima@coldmail.com', 'Dourados'),
(21, 'Felipe Gomes', '(67) 99333-4444', 'felipe.gomes@jmail.com', 'Três Lagoas'),
(22, 'Beatriz Rocha', '(67) 99444-5555', 'beatriz.rocha@inlook.com', 'Campo Grande'),
(23, 'Marcelo Dias', '(67) 99555-6666', 'marcelo.dias@hayoo.com.br', 'Corumbá'),
(24, 'Camila Alves', '(67) 99666-7777', 'camila.alves@jmail.com', 'Ponta Porã'),
(25, 'Thiago Costa', '(67) 99777-8888', 'thiago.costa@coldmail.com', 'Campo Grande'),
(26, 'Larissa Mendes', '(67) 99888-9999', 'larissa.mendes@jmail.com', 'Campo Grande'),
(27, 'Bruno Carvalho', '(67) 99999-0000', 'bruno.carvalho@inlook.com', 'Dourados'),
(28, 'Juliana Castro', '(67) 99000-1111', 'juliana.castro@jmail.com', 'Três Lagoas'),
(29, 'Leonardo Santos', '(67) 99123-9876', 'leonardo.santos@hayoo.com.br', 'Campo Grande'),
(30, 'Natália Martins', '(67) 99876-1234', 'natalia.martins@jmail.com', 'Campo Grande'),
(31, 'Joao Silva', '(67) 99111-1234', 'joao.silva@jmail.com', 'Campo Grande'),
(32, 'Maria Oliveira', '(67) 99222-2345', 'maria.oliveira@coldmail.com', 'Dourados'),
(33, 'Carlos Souza', '(67) 99333-3456', 'carlos.souza@inlook.com', 'Três Lagoas'),
(34, 'Ana Costa', '(67) 99444-4567', 'ana.costa@hayoo.com.br', 'Corumbá'),
(35, 'Pedro Santos', '(67) 99555-5678', 'pedro.santos@jmail.com', 'Ponta Porã'),
(36, 'Paula Lima', '(67) 99666-6789', 'paula.lima@coldmail.com', 'Campo Grande'),
(37, 'Lucas Pereira', '(67) 99777-7890', 'lucas.pereira@inlook.com', 'Dourados'),
(38, 'Julia Carvalho', '(67) 99888-8901', 'julia.carvalho@hayoo.com.br', 'Três Lagoas'),
(39, 'Marcos Rodrigues', '(67) 99999-9012', 'marcos.rodrigues@jmail.com', 'Corumbá'),
(40, 'Fernanda Almeida', '(67) 99123-0123', 'fernanda.almeida@coldmail.com', 'Ponta Porã'),
(41, 'Rafael Alves', '(67) 99234-1234', 'rafael.alves@inlook.com', 'Campo Grande'),
(42, 'Camila Ribeiro', '(67) 99345-2345', 'camila.ribeiro@hayoo.com.br', 'Dourados'),
(43, 'Bruno Martins', '(67) 99456-3456', 'bruno.martins@jmail.com', 'Três Lagoas'),
(44, 'Leticia Gomes', '(67) 99567-4567', 'leticia.gomes@coldmail.com', 'Corumbá'),
(45, 'Thiago Dias', '(67) 99678-5678', 'thiago.dias@inlook.com', 'Ponta Porã'),
(46, 'Amanda Rocha', '(67) 99789-6789', 'amanda.rocha@hayoo.com.br', 'Campo Grande'),
(47, 'Diego Castro', '(67) 99890-7890', 'diego.castro@jmail.com', 'Dourados'),
(48, 'Beatriz Mendes', '(67) 99901-8901', 'beatriz.mendes@coldmail.com', 'Três Lagoas'),
(49, 'Felipe Nunes', '(67) 99012-9012', 'felipe.nunes@inlook.com', 'Corumbá'),
(50, 'Mariana Cardoso', '(67) 99123-1111', 'mariana.cardoso@hayoo.com.br', 'Ponta Porã');

-- products: 65 records.
INSERT INTO public.products (product_id, price_brl, name, category_id, description, stock_quantity, status, specs, created_at) VALUES
(81, 599.9, 'Yamaha C40 Nylon Natural', 5, 'Violão clássico com tampo em Spruce e fundo/laterais em Meranti. Ideal para estudantes e iniciantes, com excelente projeção sonora.', 12, 'active', '{"top":"Spruce","back_sides":"Meranti","neck":"Nato","strings":"nylon","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2021-03-15'),
(82, 849, 'Yamaha C70 Nylon Natural', 5, 'Violão clássico de nível intermediário com tampo em Spruce sólido. Acabamento de alta qualidade e timbre equilibrado.', 8, 'active', '{"top":"Spruce Sólido","back_sides":"Nato","neck":"Nato","strings":"nylon","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2021-06-20'),
(83, 429.9, 'Tagima Memphis AC-39 Nylon Natural', 5, 'Violão clássico com cordas de nylon, perfeito para quem está começando. Corpo leve e confortável para longas sessões de estudo.', 15, 'active', '{"top":"Linden","back_sides":"Linden","neck":"Nato","strings":"nylon","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2020-08-10'),
(84, 689, 'Giannini GN-15 Nylon Cedr Natural', 5, 'Violão clássico Giannini com tampo em cedro. Sonoridade quente e encorpada, excelente custo-benefício para estudantes avançados.', 6, 'active', '{"top":"Cedro","back_sides":"Sapele","neck":"Cedro","strings":"nylon","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2022-01-05'),
(85, 459.9, 'Rozini RC-104 Nylon Estudante', 5, 'Violão clássico de estudo da Rozini, feito com madeiras nacionais. Acabamento caprichado e preço acessível para iniciantes.', 10, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"nylon","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2020-04-22'),
(86, 749, 'Tagima Dallas Tuner Aço Natural', 5, 'Violão folk com cordas de aço e afinador integrado. Corpo confortável e som brilhante, ideal para acompanhamento vocal.', 9, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"steel","scale":"648mm","electronics":"no","color":"Natural"}'::jsonb, '2021-09-14'),
(87, 699.9, 'Yamaha F310 Aço Natural', 5, 'Violão folk aço Yamaha com corpo robusto e timbre encorpado. Um dos modelos mais vendidos do mundo para iniciantes e intermediários.', 14, 'active', '{"top":"Spruce","back_sides":"Meranti","neck":"Nato","strings":"steel","scale":"634mm","electronics":"no","color":"Natural"}'::jsonb, '2020-11-30'),
(88, 579.9, 'Giannini GF-1R Aço Folk Sunburst', 5, 'Violão folk com tampo em Spruce e acabamento Sunburst clássico. Som equilibrado e visual elegante para palco e estúdio.', 7, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"steel","scale":"648mm","electronics":"no","color":"Sunburst"}'::jsonb, '2022-05-18'),
(89, 549, 'Shelby SN-100 Folk Aço Preto', 5, 'Violão folk aço com visual moderno em preto. Indicado para quem busca um instrumento versátil com boa relação custo-benefício.', 5, 'active', '{"top":"Linden","back_sides":"Linden","neck":"Nato","strings":"steel","scale":"648mm","electronics":"no","color":"Preto"}'::jsonb, '2023-02-10'),
(90, 2399, 'Crafter HT-100 Folk Aço Natural', 5, 'Violão folk de alta qualidade com tampo sólido em Spruce Engelmann. Projeção sonora superior e acabamento impecável.', 3, 'active', '{"top":"Spruce Engelmann Sólido","back_sides":"Mogno","neck":"Mogno","strings":"steel","scale":"648mm","electronics":"no","color":"Natural"}'::jsonb, '2021-07-25'),
(91, 899, 'Tagima Woodstock Dreadnought Natural', 5, 'Violão dreadnought com corpo amplo e som potente. Excelente para fingerpicking e strumming com projeção impressionante.', 11, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"steel","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2022-03-08'),
(92, 1299, 'Yamaha FG800 Dreadnought Natural', 5, 'Violão dreadnought Yamaha com tampo sólido em Spruce. Tecnologia de bracing exclusiva para som rico e encorpado.', 7, 'active', '{"top":"Spruce Sólido","back_sides":"Nato","neck":"Nato","strings":"steel","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2020-06-15'),
(93, 11499, 'Martin D-28 Dreadnought Natural', 5, 'Lendário violão Martin D-28 com tampo sólido em Sitka Spruce e fundo em Rosewood. Referência mundial em sonoridade e construção.', 2, 'active', '{"top":"Sitka Spruce Sólido","back_sides":"East Indian Rosewood","neck":"Select Hardwood","strings":"steel","scale":"645mm","electronics":"no","color":"Natural"}'::jsonb, '2023-01-20'),
(94, 5999, 'Taylor 110e Dreadnought Natural', 5, 'Violão dreadnought Taylor com tampo sólido em Sitka Spruce e eletrônica ES2. Perfeito para palco com som amplificado de alta fidelidade.', 4, 'active', '{"top":"Sitka Spruce Sólido","back_sides":"Walnut","neck":"Tropical Mahogany","strings":"steel","scale":"648mm","electronics":"yes","color":"Natural"}'::jsonb, '2022-09-12'),
(95, 2199, 'Takamine GD20 Dreadnought Natural', 5, 'Violão dreadnought Takamine com tampo sólido em cedro. Excelente para fingerstyle com timbre quente e definido.', 5, 'active', '{"top":"Cedro Sólido","back_sides":"Sapele","neck":"Mogno","strings":"steel","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2021-11-03'),
(96, 799.9, 'Giannini GF-3D Dreadnought Sunburst', 5, 'Violão dreadnought com corpo amplo e acabamento Sunburst. Volume alto e graves profundos, ideal para country e pop.', 0, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"steel","scale":"650mm","electronics":"no","color":"Sunburst"}'::jsonb, '2020-02-28'),
(97, 4599, 'Crafter D-8 Dreadnought Natural', 5, 'Violão dreadnought premium com tampo sólido em Spruce Sitka e fundo em Rosewood. Acabamento artesanal e som excepcional.', 2, 'active', '{"top":"Sitka Spruce Sólido","back_sides":"Rosewood","neck":"Mogno","strings":"steel","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2023-05-14'),
(98, 3499, 'Yamaha NTX1 Elétrico Nylon Natural', 5, 'Violão eletroacústico com cordas de nylon e captação Atmosfeel. Braço estreito e corpo fino para conforto máximo em apresentações ao vivo.', 6, 'active', '{"top":"Spruce Sólido","back_sides":"Nato","neck":"Nato","strings":"nylon","scale":"650mm","electronics":"yes","color":"Natural"}'::jsonb, '2022-04-20'),
(99, 1199, 'Tagima Classical Elétrico Nylon Sunburst', 5, 'Violão eletroacústico nylon com pré-amplificador e afinador embutido. Versátil para palco e estúdio com excelente resposta tonal.', 8, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"nylon","scale":"650mm","electronics":"yes","color":"Sunburst"}'::jsonb, '2021-08-07'),
(100, 3299, 'Takamine GC5CE Elétrico Nylon Natural', 5, 'Violão eletroacústico clássico com captação TP-4T e tampo sólido em Spruce. Ideal para músicos profissionais que precisam de amplificação.', 3, 'active', '{"top":"Spruce Sólido","back_sides":"Rosewood","neck":"Mogno","strings":"nylon","scale":"650mm","electronics":"yes","color":"Natural"}'::jsonb, '2023-07-30'),
(101, 1049, 'Giannini GNF-3 CEQ Elétrico Nylon Natural', 5, 'Violão eletroacústico nylon Giannini com equalizador de 4 bandas. Construção robusta e som amplificado de qualidade profissional.', 4, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"nylon","scale":"650mm","electronics":"yes","color":"Natural"}'::jsonb, '2020-10-15'),
(102, 3899, 'Crafter CE-15 Elétrico Nylon Natural', 5, 'Violão eletroacústico nylon Crafter com sistema de captação LR Baggs. Tampo sólido e projeção excepcional tanto acústica quanto amplificada.', 2, 'active', '{"top":"Cedro Sólido","back_sides":"Rosewood","neck":"Mogno","strings":"nylon","scale":"650mm","electronics":"yes","color":"Natural"}'::jsonb, '2024-01-10'),
(103, 1349, 'Tagima Vegas Elétrico Aço Natural', 5, 'Violão eletroacústico aço com corpo Folk e captação ativa. Som brilhante amplificado com presença marcante nos médios.', 9, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"steel","scale":"648mm","electronics":"yes","color":"Natural"}'::jsonb, '2022-06-25'),
(104, 1899, 'Yamaha APX600 Elétrico Aço Preto', 5, 'Violão eletroacústico Yamaha com corpo slim e captação piezo. Design moderno e confortável para performances no palco.', 7, 'active', '{"top":"Spruce","back_sides":"Nato","neck":"Nato","strings":"steel","scale":"634mm","electronics":"yes","color":"Preto"}'::jsonb, '2021-04-18'),
(105, 4199, 'Takamine GN51CE Elétrico Aço Natural', 5, 'Violão eletroacústico NEX com tampo sólido em Spruce e pré-amplificador CTP-3. Versatilidade tonal para diversos estilos musicais.', 3, 'active', '{"top":"Spruce Sólido","back_sides":"Walnut","neck":"Mogno","strings":"steel","scale":"648mm","electronics":"yes","color":"Natural"}'::jsonb, '2023-03-05'),
(106, 7499, 'Taylor 214ce Elétrico Aço Natural', 5, 'Violão eletroacústico Taylor Grand Auditorium com tampo sólido em Sitka Spruce. Sistema ES2 para som amplificado cristalino.', 2, 'active', '{"top":"Sitka Spruce Sólido","back_sides":"Layered Rosewood","neck":"Tropical Mahogany","strings":"steel","scale":"648mm","electronics":"yes","color":"Natural"}'::jsonb, '2024-02-14'),
(107, 799, 'Shelby SGD-195E Elétrico Aço Sunburst', 5, 'Violão eletroacústico dreadnought com captação e afinador integrado. Boa opção de custo-benefício para quem precisa de amplificação.', 6, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"steel","scale":"650mm","electronics":"yes","color":"Sunburst"}'::jsonb, '2022-12-01'),
(108, 12000, 'Martin D-28E Elétrico Aço Natural', 5, 'O lendário Martin D-28 com captação LR Baggs Anthem. Todo o timbre clássico do D-28 com amplificação de nível profissional.', 1, 'active', '{"top":"Sitka Spruce Sólido","back_sides":"East Indian Rosewood","neck":"Select Hardwood","strings":"steel","scale":"645mm","electronics":"yes","color":"Natural"}'::jsonb, '2024-05-20'),
(109, 1299, 'Rozini RV-174 7 Cordas Nylon Natural', 5, 'Violão 7 cordas com tampo em Spruce e braço reforçado. Ideal para choro e samba com baixaria rica e definida.', 5, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Cedro","strings":"nylon","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2020-09-08'),
(110, 1149, 'Giannini GWNE-7 7 Cordas Nylon Natural', 5, 'Violão de 7 cordas Giannini para choro e MPB. Construção brasileira tradicional com excelente resposta nos graves.', 4, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Cedro","strings":"nylon","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2021-01-22'),
(111, 1699, 'Rozini RV-175 7 Cordas Elétrico Natural', 5, 'Violão 7 cordas eletroacústico com captação sob o tampo. Perfeito para rodas de choro amplificadas e gravações em estúdio.', 3, 'active', '{"top":"Spruce Sólido","back_sides":"Jacarandá","neck":"Cedro","strings":"nylon","scale":"650mm","electronics":"yes","color":"Natural"}'::jsonb, '2022-07-15'),
(112, 999, 'Tagima TW-7 7 Cordas Aço Natural', 5, 'Violão 7 cordas com cordas de aço para estilos que exigem projeção extra. Braço confortável com tensor regulável.', 6, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"steel","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2023-04-10'),
(113, 749, 'Shelby SN-7C 7 Cordas Nylon Natural', 5, 'Violão 7 cordas clássico com acabamento natural e braço em cedro. Boa opção para estudantes de choro que buscam qualidade acessível.', 0, 'discontinued', '{"top":"Linden","back_sides":"Linden","neck":"Cedro","strings":"nylon","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2020-03-05'),
(114, 1699, 'Yamaha CG162S Nylon Natural', 5, 'Violão clássico Yamaha com tampo sólido em Spruce Engelmann. Acabamento refinado e sonoridade de concerto para estudantes avançados.', 4, 'active', '{"top":"Spruce Engelmann Sólido","back_sides":"Ovangkol","neck":"Nato","strings":"nylon","scale":"650mm","electronics":"no","color":"Natural"}'::jsonb, '2023-09-18'),
(115, 2499, 'Takamine GC1CE Elétrico Nylon Natural', 5, 'Violão eletroacústico clássico Takamine com tampo sólido em Spruce e pré TP-4T. Excelente para apresentações ao vivo com som natural.', 5, 'active', '{"top":"Spruce Sólido","back_sides":"Sapele","neck":"Mogno","strings":"nylon","scale":"650mm","electronics":"yes","color":"Natural"}'::jsonb, '2024-03-22'),
(116, 199.9, 'Kala KA-15S Soprano Mogno', 9, 'Ukulele soprano Kala com corpo em mogno e cordas Aquila. Som doce e tradicional, perfeito para iniciantes e viajantes.', 15, 'active', '{"top":"Mogno","back_sides":"Mogno","neck":"Mogno","strings":"nylon","scale":"346mm","electronics":"no","color":"Natural"}'::jsonb, '2021-05-12'),
(117, 249.9, 'Ohana SK-10 Soprano Natural', 9, 'Ukulele soprano Ohana com acabamento acetinado e cordas Aquila. Construção leve e timbre claro, ótimo custo-benefício.', 10, 'active', '{"top":"Mogno","back_sides":"Mogno","neck":"Mogno","strings":"nylon","scale":"346mm","electronics":"no","color":"Natural"}'::jsonb, '2022-02-28'),
(118, 179.9, 'Kalani KAL-300S Soprano Natural', 9, 'Ukulele soprano Kalani com tampo em Spruce e corpo em Sapele. Projeção surpreendente para um instrumento compacto.', 12, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"nylon","scale":"346mm","electronics":"no","color":"Natural"}'::jsonb, '2020-07-19'),
(119, 159.9, 'Shelby SU-21S Soprano Sunburst', 9, 'Ukulele soprano com acabamento Sunburst e escala em Rosewood. Visual clássico e som alegre para músicos de todos os níveis.', 8, 'active', '{"top":"Linden","back_sides":"Linden","neck":"Nato","strings":"nylon","scale":"346mm","electronics":"no","color":"Sunburst"}'::jsonb, '2021-10-03'),
(120, 349.9, 'Kala KA-C Concert Mogno', 9, 'Ukulele concert Kala com corpo em mogno maciço e acabamento acetinado. Escala maior para mais conforto e volume.', 9, 'active', '{"top":"Mogno","back_sides":"Mogno","neck":"Mogno","strings":"nylon","scale":"381mm","electronics":"no","color":"Natural"}'::jsonb, '2022-08-14'),
(121, 549, 'Ohana CK-20 Concert Natural', 9, 'Ukulele concert Ohana com tampo sólido em Spruce e fundo em Mogno. Tom equilibrado e sustain impressionante para a categoria.', 6, 'active', '{"top":"Spruce Sólido","back_sides":"Mogno","neck":"Mogno","strings":"nylon","scale":"381mm","electronics":"no","color":"Natural"}'::jsonb, '2023-06-20'),
(122, 479, 'Kalani KAL-500C Concert Elétrico Natural', 9, 'Ukulele concert eletroacústico com captação piezo e pré-amplificador. Versátil para palco e estúdio com timbre amplificado fiel.', 5, 'active', '{"top":"Mogno","back_sides":"Mogno","neck":"Mogno","strings":"nylon","scale":"381mm","electronics":"yes","color":"Natural"}'::jsonb, '2024-04-08'),
(123, 899, 'Kala KA-SMHCE Concert Elétrico Mogno', 9, 'Ukulele concert eletroacústico Kala com tampo sólido em mogno e captação. Acabamento premium e som rico para performances profissionais.', 3, 'active', '{"top":"Mogno Sólido","back_sides":"Mogno","neck":"Mogno","strings":"nylon","scale":"381mm","electronics":"yes","color":"Natural"}'::jsonb, '2023-11-15'),
(124, 449.9, 'Kala KA-T Tenor Mogno', 9, 'Ukulele tenor Kala em mogno com escala estendida para maior conforto. Graves mais presentes e volume superior ao soprano e concert.', 7, 'active', '{"top":"Mogno","back_sides":"Mogno","neck":"Mogno","strings":"nylon","scale":"432mm","electronics":"no","color":"Natural"}'::jsonb, '2021-12-10'),
(125, 1299, 'Ohana TK-35G Tenor Sólido Natural', 9, 'Ukulele tenor Ohana com tampo sólido em Spruce e fundo em Acácia. Projeção e definição excepcionais para músicos exigentes.', 2, 'active', '{"top":"Spruce Sólido","back_sides":"Acácia","neck":"Mogno","strings":"nylon","scale":"432mm","electronics":"no","color":"Natural"}'::jsonb, '2024-06-01'),
(126, 1599, 'Kala KA-SRT-CTG Tenor Elétrico Cedar', 9, 'Ukulele tenor eletroacústico com tampo sólido em cedro e captação. Som quente e encorpado amplificado, ideal para apresentações ao vivo.', 4, 'active', '{"top":"Cedro Sólido","back_sides":"Acácia","neck":"Mogno","strings":"nylon","scale":"432mm","electronics":"yes","color":"Natural"}'::jsonb, '2023-08-22'),
(127, 359, 'Kalani KAL-700T Tenor Natural', 9, 'Ukulele tenor Kalani com corpo em Sapele e tampo em Spruce. Boa relação custo-benefício para quem busca um instrumento maior.', 11, 'active', '{"top":"Spruce","back_sides":"Sapele","neck":"Nato","strings":"nylon","scale":"432mm","electronics":"no","color":"Natural"}'::jsonb, '2022-10-30'),
(128, 599, 'Kala KA-B Barítono Mogno', 9, 'Ukulele barítono Kala em mogno com afinação em DGBE. Corpo amplo com graves profundos, uma ponte entre o ukulele e o violão.', 4, 'active', '{"top":"Mogno","back_sides":"Mogno","neck":"Mogno","strings":"nylon","scale":"502mm","electronics":"no","color":"Natural"}'::jsonb, '2021-02-17'),
(129, 1899, 'Ohana BK-35E Barítono Elétrico Natural', 9, 'Ukulele barítono eletroacústico com tampo sólido e captação integrada. Projeção impressionante e versatilidade para músicos de palco.', 1, 'active', '{"top":"Spruce Sólido","back_sides":"Acácia","neck":"Mogno","strings":"nylon","scale":"502mm","electronics":"yes","color":"Natural"}'::jsonb, '2024-01-30'),
(130, 1749, 'Kala KA-ABP-CTG Barítono Cedar', 9, 'Ukulele barítono premium com tampo sólido em cedro e fundo em Pau Ferro. Sonoridade madura e profunda, perfeito para arranjos complexos.', 2, 'coming_soon', '{"top":"Cedro Sólido","back_sides":"Pau Ferro","neck":"Mogno","strings":"nylon","scale":"502mm","electronics":"no","color":"Natural"}'::jsonb, '2025-05-15'),
(145, 12500, 'Fender Stratocaster American Pro II', 1, 'Guitarra elétrica Fender Stratocaster com 3 captadores V-Mod II single-coil. Clássico timbre brilhante e versátil para diversos estilos.', 5, 'active', '{"body":"Alder","neck":"Maple","strings":"6","color":"Sunburst"}'::jsonb, '2023-01-15'),
(131, 18900, 'Gibson Les Paul Standard ''50s', 1, 'Guitarra elétrica Gibson Les Paul com captadores Burstbucker. Timbre encorpado e sustain infinito, ideal para rock e blues.', 2, 'active', '{"body":"Mahogany","neck":"Mahogany","strings":"6","color":"Heritage Cherry Sunburst"}'::jsonb, '2022-11-10'),
(132, 7500, 'Ibanez RG550 Genesis Collection', 1, 'Guitarra elétrica Ibanez RG com ponte Edge tremolo e captadores V7/S1/V8. Braço Super Wizard super rápido para shred e metal.', 8, 'active', '{"body":"Basswood","neck":"Maple/Walnut","strings":"6","color":"Desert Sun Yellow"}'::jsonb, '2023-05-20'),
(133, 6800, 'PRS SE Custom 24', 1, 'Guitarra elétrica PRS SE com 24 trastes e captadores 85/15 "S". Versatilidade incrível com split de bobina e visual deslumbrante.', 12, 'active', '{"body":"Mahogany/Maple","neck":"Maple","strings":"6","color":"Eriza Verde"}'::jsonb, '2024-02-05'),
(134, 5400, 'Fender Telecaster Player Series', 1, 'Guitarra elétrica Fender Telecaster com 2 captadores Player Series Alnico 5. O autêntico "twang" da Fender com tocabilidade moderna.', 15, 'active', '{"body":"Alder","neck":"Maple","strings":"6","color":"Butterscotch Blonde"}'::jsonb, '2023-08-12'),
(135, 8732, 'Music Man Bass 1X Electric Bass', 2, 'Contrabaixo elétrico Fender Jazz Bass com corpo em Alder e dois captadores single-coil. Timbre estalado e versatilidade lendária para funk e rock.', 9, 'active', '{"body": "Ash", "neck": "Maple", "strings": "4", "color": "Red"}'::jsonb, '2023-06-20'),
(136, 441, 'Ibanez Bass 2X Electric Bass', 2, 'Contrabaixo Precision de 4 cordas com captação split-coil. O clássico peso e punch nos graves, perfeito para gravações em estúdio.', 13, 'discontinued', '{"body": "Ash", "neck": "Maple", "strings": "4", "color": "Red"}'::jsonb, '2021-08-07'),
(137, 11445, 'Yamaha Bass 3X Electric Bass', 2, 'Contrabaixo ativo de 5 cordas Ibanez com equalizador de 3 bandas. Braço rápido e confortável para linhas de baixo modernas e slap.', 11, 'active', '{"body": "Ash", "neck": "Maple", "strings": "4", "color": "Black"}'::jsonb, '2023-07-30'),
(138, 7157, 'Music Man Bass 4X Electric Bass', 2, 'Contrabaixo elétrico Music Man StingRay com captador humbucker na ponte. Ataque agressivo e definição impecável para rock e metal.', 9, 'active', '{"body": "Ash", "neck": "Maple", "strings": "4", "color": "Black"}'::jsonb, '2020-10-15'),
(139, 4439, 'Bateria Acústica Yamaha Kit 1 Studio', 3, 'Bateria acústica Pearl Export com cascos em Poplar e mogno asiático. Sonoridade encorpada e ferragens reforçadas para o dia a dia.', 8, 'active', '{"shells": "Maple", "pieces": "5", "hardware": "included", "color": "Blue"}'::jsonb, '2024-01-10'),
(140, 13285, 'Bateria Acústica Pearl Kit 2 Studio', 3, 'Bateria acústica Tama com cascos 100% Birch e sistema de suspensão Star-Mount. Ataque explosivo e excelente projeção em palcos.', 7, 'active', '{"shells": "Maple", "pieces": "5", "hardware": "included", "color": "Black"}'::jsonb, '2022-06-25'),
(141, 14922, 'Bateria Acústica Yamaha Kit 3 Studio', 3, 'Bateria acústica Yamaha Stage Custom com bumbos profundos e ferragens inclusas. O padrão de confiabilidade e som focado para shows e ensaios.', 8, 'active', '{"shells": "Maple", "pieces": "5", "hardware": "included", "color": "Wine Red"}'::jsonb, '2021-04-18'),
(142, 1127, 'Teclado Sintetizador Korg Synth 1 Pro', 4, 'Sintetizador workstation Roland com 88 teclas pesadas e motor sonoro SuperNATURAL. Ideal para produções complexas e arranjos ao vivo.', 2, 'active', '{"keys": "61", "type": "Synthesizer", "polyphony": "128", "color": "Black"}'::jsonb, '2023-03-05'),
(143, 19567, 'Teclado Sintetizador Nord Synth 2 Pro', 4, 'Piano de palco Nord Stage com seções independentes de piano, órgão e synth. Interface intuitiva e qualidade sonora padrão da indústria.', 3, 'active', '{"keys": "61", "type": "Synthesizer", "polyphony": "128", "color": "Black"}'::jsonb, '2022-01-05'),
(144, 9351, 'Teclado Sintetizador Roland Synth 3 Pro', 4, 'Teclado arranjador Yamaha com 61 teclas sensitivas e acompanhamentos realistas. Ótima opção de custo-benefício para estudantes e apresentações solo.', 8, 'active', '{"keys": "61", "type": "Synthesizer", "polyphony": "128", "color": "Black"}'::jsonb, '2020-04-22');

-- orders: 20 records.
INSERT INTO public.orders (order_id, customer_id, order_date, status, total_brl, payment_method, tracking_code, estimated_delivery, notes) VALUES
(1, 3, '2025-10-15', 'delivered', 11499, 'pix', 'BRAB1234567BR', '2025-10-25', NULL),
(2, 7, '2025-11-02', 'delivered', 5999, 'credit_6x', 'BRCX9876543BR', '2025-11-15', NULL),
(3, 12, '2025-11-20', 'delivered', 3450, 'credit_12x', 'BRDZ4561230BR', '2025-12-05', NULL),
(4, 1, '2025-12-10', 'delivered', 799.9, 'boleto', 'BRQM7890123BR', '2025-12-22', NULL),
(5, 5, '2026-01-05', 'delivered', 4599, 'pix', 'BRTP3456789BR', '2026-01-18', NULL),
(6, 9, '2026-01-18', 'delivered', 7499, 'credit_12x', 'BRVN6543210BR', '2026-02-01', NULL),
(7, 14, '2026-02-03', 'delivered', 159.9, 'credit_3x', 'BRKR1122334BR', '2026-02-17', NULL),
(8, 2, '2026-02-15', 'shipped', 349.9, 'debit', 'BRJL5544332BR', '2026-02-28', NULL),
(9, 6, '2026-02-20', 'confirmed', 349.9, 'credit_6x', NULL, NULL, NULL),
(10, 11, '2026-02-25', 'confirmed', 8732, 'pix', NULL, NULL, NULL),
(11, 4, '2026-03-05', 'confirmed', 359, 'boleto', NULL, NULL, NULL),
(12, 16, '2026-03-10', 'confirmed', 599, 'credit_3x', NULL, NULL, NULL),
(13, 8, '2026-03-12', 'pending', 1899, 'pix', NULL, NULL, NULL),
(14, 13, '2026-03-15', 'pending', 1749, 'debit', NULL, NULL, NULL),
(15, 18, '2026-03-18', 'pending', 8348, 'credit_12x', NULL, NULL, NULL),
(16, 10, '2026-03-22', 'pending', 429.9, 'credit_6x', NULL, NULL, NULL),
(17, 15, '2026-01-28', 'cancelled', 689, 'pix', NULL, NULL, 'Pedido cancelado pelo cliente antes do processamento'),
(18, 17, '2026-02-08', 'cancelled', 459.9, 'credit_12x', NULL, NULL, 'Item fora de estoque no momento do pedido'),
(19, 3, '2026-02-22', 'cancelled', 7499, 'boleto', NULL, NULL, 'Pagamento não confirmado dentro do prazo'),
(20, 7, '2026-03-08', 'cancelled', 1400, 'credit_3x', NULL, NULL, 'Endereço de entrega inválido informado pelo cliente');

-- order_items: 22 records.
INSERT INTO public.order_items (order_id, quantity, product_id) VALUES
(1, 1, 93),
(2, 1, 94),
(3, 2, 130),
(4, 1, 96),
(5, 1, 97),
(6, 1, 106),
(7, 1, 119),
(8, 1, 120),
(9, 1, 120),
(10, 1, 135),
(11, 1, 127),
(12, 1, 128),
(13, 1, 129),
(14, 1, 130),
(15, 1, 82),
(15, 1, 106),
(16, 1, 83),
(17, 1, 84),
(18, 1, 85),
(19, 1, 106),
(20, 1, 107),
(20, 1, 84);

-- promotions: 25 records.
INSERT INTO public.promotions (promotion_id, product_id, discount_percent, description, is_active) VALUES
(1, 102, 10, 'Black Friday', FALSE),
(2, 110, 15, 'Liquidação de Inverno', FALSE),
(3, 122, 20, 'Queima de Estoque', FALSE),
(4, 95, 12, 'Oferta Especial', FALSE),
(5, 126, 25, 'Aniversário da Loja', FALSE),
(6, 93, 15, 'Promoção de Páscoa', FALSE),
(7, 91, 30, 'Black Friday', FALSE),
(8, 96, 18, 'Semana do Músico', FALSE),
(9, 99, 8, 'Promoção de Páscoa', FALSE),
(10, 116, 20, 'Aniversário da Loja', FALSE),
(11, 119, 10, 'Liquidação de Inverno', FALSE),
(12, 127, 10, 'Oferta Especial', TRUE),
(13, 134, 15, 'Queima de Estoque', FALSE),
(14, 121, 20, 'Desconto Exclusivo', TRUE),
(15, 106, 12, 'Semana do Músico', FALSE),
(16, 113, 25, 'Black Friday', FALSE),
(17, 125, 30, 'Aniversário da Loja', FALSE),
(18, 133, 5, 'Oferta Especial', FALSE),
(19, 90, 18, 'Desconto Exclusivo', TRUE),
(20, 140, 22, 'Queima de Estoque', FALSE),
(21, 139, 35, 'Liquidação de Inverno', FALSE),
(22, 96, 40, 'Semana do Músico', FALSE),
(23, 93, 10, 'Promoção de Páscoa', FALSE),
(24, 94, 8, 'Desconto Exclusivo', TRUE),
(25, 99, 14, 'Aniversário da Loja', FALSE);

SELECT setval(pg_get_serial_sequence('public.categories', 'category_id'), (SELECT MAX(category_id) FROM public.categories), true);

SELECT setval(pg_get_serial_sequence('public.customers', 'customer_id'), (SELECT MAX(customer_id) FROM public.customers), true);

SELECT setval(pg_get_serial_sequence('public.products', 'product_id'), (SELECT MAX(product_id) FROM public.products), true);

SELECT setval(pg_get_serial_sequence('public.orders', 'order_id'), (SELECT MAX(order_id) FROM public.orders), true);

SELECT setval(pg_get_serial_sequence('public.promotions', 'promotion_id'), (SELECT MAX(promotion_id) FROM public.promotions), true);

COMMIT;

-- Verification: expected total of 191 records in source tables.
SELECT 'categories' AS tabela, count(*) AS registros FROM public.categories
UNION ALL
SELECT 'customers' AS tabela, count(*) AS registros FROM public.customers
UNION ALL
SELECT 'products' AS tabela, count(*) AS registros FROM public.products
UNION ALL
SELECT 'orders' AS tabela, count(*) AS registros FROM public.orders
UNION ALL
SELECT 'order_items' AS tabela, count(*) AS registros FROM public.order_items
UNION ALL
SELECT 'promotions' AS tabela, count(*) AS registros FROM public.promotions;
