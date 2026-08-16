import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { onMessagePublished } from "firebase-functions/v2/pubsub";
import { google } from "googleapis";
import * as http2 from "http2";
import * as jwt from "jsonwebtoken";
import { defineSecret } from "firebase-functions/params";

admin.initializeApp();
const db = admin.firestore();

// Declaração do segredo configurado no Firebase Secret Manager (Arquivo .p8)
const apnsPrivateKey = defineSecret("APNS_PRIVATE_KEY");

/**
 * FIREBASE CRON JOB: Gerador Mensal de Faturas e Sessões
 */
export const rotinaMensalPsicoFlow = onSchedule("0 2 1 * *", async (event) => {
    console.log("Iniciando rotina mensal de faturamento e agendamento...");

    const hoje = new Date();
    const anoAtual = hoje.getFullYear();
    const mesAtual = hoje.getMonth();

    const mesFormatado = String(mesAtual + 1).padStart(2, '0');
    const mesReferencia = `${anoAtual}/${mesFormatado}`;
    
    const ultimoDiaProximoMes = new Date(anoAtual, mesAtual + 2, 0);

    try {
        const usersSnapshot = await db.collection("users").get();

        for (const userDoc of usersSnapshot.docs) {
            const userId = userDoc.id;

            const patientsSnapshot = await db.collection(`users/${userId}/patients`)
                .where("status", "==", "ativo")
                .get();

            const pacientesAtivosIds = patientsSnapshot.docs.map(doc => doc.id);

            for (const patientDoc of patientsSnapshot.docs) {
                const paciente = patientDoc.data();
                const pacienteId = patientDoc.id;

                const pagamentosSnapshot = await db.collection(`users/${userId}/payments`)
                    .where("pacienteID", "==", pacienteId)
                    .where("mesReferencia", "==", mesReferencia)
                    .get();

                if (pagamentosSnapshot.empty) {
                    const novoPagamentoRef = db.collection(`users/${userId}/payments`).doc();
                    await novoPagamentoRef.set({
                        id: novoPagamentoRef.id,
                        psicologoID: userId,
                        pacienteID: pacienteId,
                        mesReferencia: mesReferencia,
                        dataPagamento: null,
                        valor: paciente.valor || 0.0,
                        pago: false
                    });
                }
            }

            const regrasSnapshot = await db.collection(`users/${userId}/fixed_sessions`).get();
            const sessoesExistentesSnapshot = await db.collection(`users/${userId}/sessions`).get();
            const sessoesExistentes = sessoesExistentesSnapshot.docs.map(doc => doc.data());

            for (const regraDoc of regrasSnapshot.docs) {
                const regra = regraDoc.data();

                if (pacientesAtivosIds.includes(regra.pacienteID)) {
                    let dataAtual = new Date(hoje.getTime());
                    
                    while (dataAtual <= ultimoDiaProximoMes) {
                        const diaSemanaSwift = dataAtual.getDay() + 1;

                        if (diaSemanaSwift === regra.diaDaSemana) {
                            const dataDaNovaSessao = new Date(dataAtual.getFullYear(), dataAtual.getMonth(), dataAtual.getDate(), 12, 0, 0);
                            
                            const jaExiste = sessoesExistentes.some(sessao => {
                                if (sessao.sessaoFixaID !== regra.id) return false;
                                
                                // Lê a data como Timestamp
                                const dataDaSessaoExistente = sessao.dataDaSessao.toDate();
                                return dataDaSessaoExistente.getDate() === dataDaNovaSessao.getDate() &&
                                       dataDaSessaoExistente.getMonth() === dataDaNovaSessao.getMonth() &&
                                       dataDaSessaoExistente.getFullYear() === dataDaNovaSessao.getFullYear();
                            });

                            if (!jaExiste) {
                                const novaSessaoRef = db.collection(`users/${userId}/sessions`).doc();
                                await novaSessaoRef.set({
                                    id: novaSessaoRef.id,
                                    psicologoID: userId,
                                    pacienteID: regra.pacienteID,
                                    sessaoFixaID: regra.id,
                                    // Grava como Timestamp
                                    dataDaSessao: admin.firestore.Timestamp.fromDate(dataDaNovaSessao),
                                    status: "Agendada", // Corrigido para Maiúscula
                                    modalidade: regra.modalidade,
                                    horaInicio: regra.horaInicio
                                });
                            }
                        }
                        dataAtual.setDate(dataAtual.getDate() + 1);
                    }
                }
            }
        }
        console.log("Manutenção mensal concluída com sucesso!");
    } catch (error) {
        console.error("Erro na rotina mensal: ", error);
    }
});

/**
 * BOTÃO DE PÂNICO: Trava de Segurança Financeira
 */
export const cortarFaturamentoSeNecessario = onMessagePublished("orcamento-estourado", async (event) => {
    try {
        const pubSubMessage = event.data.message;
        const messageString = pubSubMessage.data ? Buffer.from(pubSubMessage.data, 'base64').toString() : '{}';
        const budgetNotification = JSON.parse(messageString);
        
        const costAmount = budgetNotification.costAmount || 0;
        const budgetAmount = budgetNotification.budgetAmount || 0;

        console.log(`Alerta de Orçamento! Gasto atual: ${costAmount} de ${budgetAmount}`);

        if (costAmount >= budgetAmount) {
            const projectId = process.env.GCP_PROJECT || "psyes-17598";
            
            const auth = new google.auth.GoogleAuth({ scopes: ['https://www.googleapis.com/auth/cloud-billing'] });
            const billing = google.cloudbilling({ version: 'v1', auth: auth });

            const projectBillingInfoName = `projects/${projectId}/billingInfo`;

            await billing.projects.updateBillingInfo({
                name: projectBillingInfoName,
                requestBody: { billingAccountName: "" },
            });

            console.log(`SEGURANÇA ATIVADA: Faturamento do projeto ${projectId} foi desativado com sucesso!`);
        }
    } catch (error) {
        console.error("Erro ao cortar faturamento:", error);
    }
});

/**
 * LIVE ACTIVITY: Push-to-Start Apple
 */
export const dispararLiveActivity = onSchedule(
    {
        schedule: "0 * * * *", 
        secrets: [apnsPrivateKey]
    },
    async (event) => {
        try {
            console.log("Iniciando rotina de Live Activities...");
            
            const BUNDLE_ID = "com.kenay.psyes"; 
            const TEAM_ID = "MR7Z669DU4"; 
            const KEY_ID = "LP5X5L67MW"; 

            // =========================================================
            // PREPARAÇÃO: Autenticação Única com a Apple
            // =========================================================
            const privateKey = apnsPrivateKey.value().replace(/\\n/g, '\n');
            const apnsToken = jwt.sign(
                { iss: TEAM_ID, iat: Math.floor(Date.now() / 1000) },
                privateKey,
                { algorithm: "ES256", header: { alg: "ES256", kid: KEY_ID } }
            );
            const client = http2.connect("https://api.sandbox.push.apple.com");

            // =========================================================
            // ETAPA 1: FAXINA (Encerrar Live Activities da hora anterior)
            // =========================================================
            console.log("Verificando atividades da hora anterior para encerrar...");
            const usersSnapshot = await db.collection("users").get();
            let encerradas = 0;

            for (const userDoc of usersSnapshot.docs) {
                const userData = userDoc.data();
                const updateToken = userData.liveActivityUpdateToken;

                if (updateToken) {
                    const endPayload = {
                        "aps": {
                            "timestamp": Math.floor(Date.now() / 1000),
                            "event": "end", // Comando de morte
                            "dismissal-date": Math.floor(Date.now() / 1000), // Força sumir da tela
                            // O iOS EXIGE o estado final para aceitar o encerramento
                            "content-state": {
                                "statusMensagem": "Sessão finalizada."
                            }
                        }
                    };

                    await new Promise((resolve) => {
                        const req = client.request({
                            ":method": "POST",
                            ":path": `/3/device/${updateToken}`, // Usando o Update Token
                            "authorization": `bearer ${apnsToken}`,
                            "apns-push-type": "liveactivity",
                            "apns-topic": `${BUNDLE_ID}.push-type.liveactivity`,
                            "apns-priority": "10"
                        });

                        req.on('end', () => { resolve(true); });
                        req.on('error', () => { resolve(false); });
                        req.write(JSON.stringify(endPayload));
                        req.end();
                    });

                    // Deleta o token do banco para não tentar matar duas vezes no futuro
                    await userDoc.ref.update({
                        liveActivityUpdateToken: admin.firestore.FieldValue.delete()
                    });
                    encerradas++;
                }
            }
            console.log(`${encerradas} Live Activities antigas foram encerradas.`);

            // =========================================================
            // ETAPA 2: BUSCAR E INICIAR NOVAS SESSÕES
            // =========================================================
            const agora = new Date();
            const daquiUmaHora = new Date(agora.getTime() + 60 * 60000);

            const horaBrasil = daquiUmaHora.toLocaleString("pt-BR", { timeZone: "America/Sao_Paulo", hour: "2-digit", hour12: false });
            const horaAlvo = `${horaBrasil}:00`; 

            const formatter = new Intl.DateTimeFormat("pt-BR", {
                timeZone: "America/Sao_Paulo", year: "numeric", month: "2-digit", day: "2-digit"
            });
            const partes = formatter.formatToParts(daquiUmaHora);
            const dia = partes.find(p => p.type === 'day')?.value;
            const mes = partes.find(p => p.type === 'month')?.value;
            const ano = partes.find(p => p.type === 'year')?.value;
            
            const inicioDoDiaTs = admin.firestore.Timestamp.fromDate(new Date(`${ano}-${mes}-${dia}T00:00:00.000-03:00`));
            const fimDoDiaTs = admin.firestore.Timestamp.fromDate(new Date(`${ano}-${mes}-${dia}T23:59:59.999-03:00`));

            console.log(`Buscando sessões de hoje com horaInicio ${horaAlvo}...`);

            const sessoesSnapshot = await db.collectionGroup("sessions")
                .where("status", "==", "Agendada")
                .where("horaInicio", "==", horaAlvo)
                .where("dataDaSessao", ">=", inicioDoDiaTs)
                .where("dataDaSessao", "<=", fimDoDiaTs)
                .get();

            if (sessoesSnapshot.empty) {
                console.log("Nenhuma sessão iminente encontrada.");
                return; // O código para aqui se não tiver nova sessão (mas a faxina já rodou!)
            }

            let disparosEfetuados = 0;

            for (const doc of sessoesSnapshot.docs) {
                const sessao = doc.data();
                
                const pacienteDoc = await db.collection(`users/${sessao.psicologoID}/patients`).doc(sessao.pacienteID).get();
                const paciente = pacienteDoc.data();
                if (!paciente) continue;

                const psicologoDoc = await db.collection("users").doc(sessao.psicologoID).get();
                const psicologo = psicologoDoc.data();
                const deviceToken = psicologo?.liveActivityToken;

                if (!deviceToken) {
                    console.log(`Psicólogo ${sessao.psicologoID} não possui token de início.`);
                    continue;
                }

                const payload = {
                    "aps": {
                        "timestamp": Math.floor(Date.now() / 1000),
                        "event": "start", 
                        "content-state": {
                            "statusMensagem": "Sessão começa em breve."
                        },
                        "attributes-type": "SessionActivityAttributes", 
                        "attributes": {
                            "nomePaciente": paciente.nome || "Paciente",
                            "modalidade": sessao.modalidade || "Presencial",
                            "isFixa": Boolean(sessao.sessaoFixaID),
                            "horaInicio": sessao.horaInicio || "00:00"
                        },
                        "alert": {
                            "title": "Próxima Sessão",
                            "body": `Atendimento com ${paciente.nome || "Paciente"} começa às ${sessao.horaInicio || "00:00"}.`
                        }
                    }
                };

                await new Promise((resolve) => {
                    const req = client.request({
                        ":method": "POST",
                        ":path": `/3/device/${deviceToken}`, // Usando o Token de Início
                        "authorization": `bearer ${apnsToken}`,
                        "apns-push-type": "liveactivity",
                        "apns-topic": `${BUNDLE_ID}.push-type.liveactivity`,
                        "apns-priority": "10" 
                    });

                    let respostaApple = '';
                    req.on('data', (chunk) => { respostaApple += chunk; });
                    
                    req.on('end', () => {
                        disparosEfetuados++;
                        resolve(true);
                    });

                    req.on('error', (err) => {
                        console.error("Erro de conexão com a Apple:", err);
                        resolve(false);
                    });

                    req.write(JSON.stringify(payload));
                    req.end();
                });

                // =========================================================
                // DISPARO DUPLO: Background Wake
                // =========================================================
                const fcmToken = psicologo?.fcmToken;
                if (fcmToken) {
                    try {
                        await admin.messaging().send({
                            token: fcmToken,
                            apns: {
                                payload: {
                                    aps: {
                                        "content-available": 1 // A ordem militar para o iOS acordar o app
                                    }
                                }
                            }
                        });
                        console.log(`Despertador silencioso disparado para o usuário ${sessao.psicologoID}`);
                    } catch (err) {
                        console.error(`Erro ao enviar despertador silencioso para ${sessao.psicologoID}:`, err);
                    }
                }

            }

            console.log(`${disparosEfetuados} novas Live Activities acionadas com sucesso!`);

        } catch (error) {
            console.error("Erro ao disparar Live Activity: ", error);
        }
    }
);