# PsicoFlow

Aplicativo de gestão para profissionais de Psicologia, desenvolvido com SwiftUI e pensado para demonstrar boas práticas de arquitetura, teste e experiência do usuário.

Resumo rápido

- Plataforma: iOS (Swift / SwiftUI)
- Módulos principais: Dashboard, Agenda, Prontuários e Faturamento
- Abordagem arquitetural: Estrutura altamente desacoplada usando Repositórios, Serviços e MVVM

---

Visão geral

O PsicoFlow é um projeto de portfólio que reúne funcionalidades essenciais para o dia a dia de um psicólogo: organização da agenda, registro de atendimentos (prontuários), acompanhamento financeiro e indicadores no dashboard. O objetivo deste repositório é demonstrar habilidades técnicas em desenvolvimento iOS moderno, clareza arquitetural e capacidade de projetar aplicações modulares e testáveis.

Demonstração

Adicione imagens, GIFs ou um vídeo de demonstração aqui para destacar a interface e fluxos principais. Sugestões:

- assets/screenshots/dashboard.png
- assets/screenshots/agenda.png
- assets/screenshots/prontuario.png

(Atualize os caminhos conforme as imagens forem adicionadas ao repositório.)

Principais funcionalidades

- Dashboard com visão consolidada de consultas e faturamento
- Agenda com criação, edição e visualização de consultas
- Prontuários estruturados para registro de atendimentos e evolução clínica
- Módulo de faturamento para registrar pagamentos e gerar relatórios
- Estrutura modular que facilita manutenção e extensão do sistema

Arquitetura e decisões técnicas

- Padrão arquitetural: MVVM para separar responsabilidades entre UI e lógica de negócio
- Camadas de dados desacopladas por Repositórios e Serviços, permitindo trocar fontes de dados (por exemplo, local vs. remoto) sem impactar a UI
- Injeção de dependências para facilitar testes e mocks
- Componentização com views reutilizáveis em SwiftUI

Nota para recrutadores: na seção de código e nos commits você encontrará exemplos de organização de pastas, convenções de nomenclatura e decisões técnicas — se desejar, posso destacar commits ou arquivos específicos que exemplifiquem cada ponto.

Tecnologias

- Swift 5+
- SwiftUI
- MVVM, Repositórios e Serviços
- Xcode (versão compatível indicada no projeto)
- Swift Package Manager (ou CocoaPods) para dependências, se aplicável

Instalação e execução (para avaliadores / recrutadores)

Pré-requisitos

- macOS com Xcode instalado (recomenda-se Xcode 13+ — verifique o projeto para a versão exata)
- Git

Passos

1. Clone o repositório:
   git clone https://github.com/kenaygn/PsicoFlow.git

2. Abra o projeto no Xcode:
   - Abra `PsicoFlow.xcodeproj` ou `PsicoFlow.xcworkspace` conforme presente

3. Instale/atualize dependências (se houver):
   - Swift Package Manager: File > Packages > Update to Latest Package Versions
   - CocoaPods: `pod install` e abra o workspace

4. Selecione um simulador ou dispositivo e rode o app (Cmd+R)

Se o projeto precisar de credenciais, variáveis de ambiente ou um backend local, descreva esses detalhes aqui (ex.: arquivo .env, instruções para popular dados iniciais).

Testes

- Execute os testes via Xcode (Product > Test ou Cmd+U)
- Descreva aqui qualquer cobertura relevante, testes unitários de componentes críticos e integração com CI (se aplicável)

O que este projeto demonstra (para recrutadores)

- Experiência prática com desenvolvimento iOS moderno (Swift + SwiftUI)
- Projeto de arquitetura desacoplada e testável (MVVM, injeção de dependência, repositórios)
- Organização de código, clareza em commits e documentação
- Capacidade de transformar requisitos de domínio (gestão de pacientes) em solução técnica

Melhorias e próximos passos (opcionais)

- Internacionalização (i18n)
- Sincronização com backend e suporte offline
- Relatórios financeiros mais completos e exportação
- Autenticação/segurança e gerenciamento de perfis profissionais

Contribuição

Este repositório é um projeto de portfólio pessoal. Se você deseja contribuir, abra uma issue ou um pull request com a proposta — mantenha o padrão de commits e siga as convenções do repositório.

Licença

Indique a licença desejada (por exemplo, MIT) e inclua um arquivo LICENSE no repositório.

Contato

- GitHub: https://github.com/kenaygn
- LinkedIn: (adicione seu perfil, ex.: https://www.linkedin.com/in/seu-nome)

---

Se quiser, eu posso:
- Adicionar badges (Swift version, build, tests)
- Gerar uma versão em inglês deste README para o público internacional
- Incluir exemplos de commits ou destacar arquivos-chave do projeto
